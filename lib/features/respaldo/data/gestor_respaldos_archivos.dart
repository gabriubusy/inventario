import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/features/respaldo/domain/archivo_respaldo.dart';
import 'package:inventario/features/respaldo/domain/gestor_respaldos.dart';
import 'package:inventario/features/respaldo/domain/resultado_respaldo.dart';

/// Backups as zip files holding `inventario.sqlite` and the `imagenes/`
/// folder, both from the app support folder [_soporte].
class GestorRespaldosArchivos implements GestorRespaldos {
  GestorRespaldosArchivos(this._db, this._soporte);

  static const nombreBase = 'inventario.sqlite';
  static const carpetaImagenes = 'imagenes';
  static const _pendiente = 'restaurar.inventario';
  static const _manifiesto = 'respaldo.json';

  final BaseDatos _db;
  final Directory _soporte;

  @override
  bool get disponible => true;

  @override
  Future<ResultadoRespaldo> respaldar(
    String carpeta, {
    required DateTime fecha,
    String prefijo = 'inventario',
  }) async {
    final destino = Directory(carpeta);
    if (!destino.existsSync()) return CarpetaNoDisponible(carpeta);
    final copia = File('${_soporte.path}${Platform.pathSeparator}respaldo.tmp');
    if (copia.existsSync()) await copia.delete();
    // A consistent snapshot even while the app keeps writing.
    await _db.customStatement('VACUUM INTO ?', [copia.path]);
    final zip = Archive()
      ..addFile(ArchiveFile.bytes(nombreBase, await copia.readAsBytes()))
      ..addFile(
        ArchiveFile.bytes(
          _manifiesto,
          utf8.encode(jsonEncode({'version': 1, 'fecha': '$fecha'})),
        ),
      );
    await copia.delete();
    final imagenes = Directory(
      '${_soporte.path}${Platform.pathSeparator}$carpetaImagenes',
    );
    if (imagenes.existsSync()) {
      await for (final entrada in imagenes.list(recursive: true)) {
        if (entrada is! File) continue;
        final relativa = entrada.path
            .substring(imagenes.path.length + 1)
            .replaceAll(r'\', '/');
        zip.addFile(
          ArchiveFile.bytes(
            '$carpetaImagenes/$relativa',
            await entrada.readAsBytes(),
          ),
        );
      }
    }
    final bytes = ZipEncoder().encode(zip);
    // Never over another backup, even two in the same second.
    var nombre = nombreRespaldo(fecha, prefijo: prefijo);
    for (var n = 2; File(_ruta(destino, nombre)).existsSync(); n++) {
      nombre = nombreRespaldo(fecha, prefijo: prefijo, copia: n);
    }
    final archivo = File(_ruta(destino, nombre));
    await archivo.writeAsBytes(bytes, flush: true);
    return RespaldoGuardado(ruta: archivo.path, bytes: bytes.length);
  }

  static String _ruta(Directory carpeta, String nombre) =>
      '${carpeta.path}${Platform.pathSeparator}$nombre';

  @override
  Future<List<ArchivoRespaldo>> enCarpeta(String carpeta) async {
    final directorio = Directory(carpeta);
    if (!directorio.existsSync()) return const [];
    final archivos = <ArchivoRespaldo>[];
    await for (final entrada in directorio.list()) {
      if (entrada is! File || !entrada.path.endsWith('.inventario')) continue;
      final datos = await entrada.stat();
      archivos.add(
        ArchivoRespaldo(
          ruta: entrada.path,
          nombre: entrada.uri.pathSegments.last,
          fecha: datos.modified,
          bytes: datos.size,
        ),
      );
    }
    return archivos..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  @override
  Future<ResultadoRespaldo> prepararRestauracion(
    String archivo, {
    required DateTime fecha,
  }) async {
    final elegido = File(archivo);
    if (!elegido.existsSync() || !_esRespaldo(await elegido.readAsBytes())) {
      return const RespaldoNoValido();
    }
    final copia = await respaldar(
      elegido.parent.path,
      fecha: fecha,
      prefijo: 'antes de restaurar',
    );
    if (copia is! RespaldoGuardado) return copia;
    await elegido.copy('${_soporte.path}${Platform.pathSeparator}$_pendiente');
    return RestauracionPreparada(copiaDeAntes: copia.ruta);
  }

  @override
  void cerrarApp() => exit(0);

  static bool _esRespaldo(List<int> bytes) {
    try {
      return ZipDecoder().decodeBytes(bytes).findFile(nombreBase) != null;
      // ArchiveException is a FormatException too.
    } on FormatException {
      return false;
    }
  }

  /// A backup that could not be applied is kept here, so the app still
  /// starts with its current data.
  static const fallido = 'restaurar-fallido.inventario';

  /// Run at start, before the database opens: puts a prepared backup in
  /// place of the database and the photos. True when it restored one.
  static Future<bool> aplicarRestauracionPendiente(Directory soporte) async {
    final separador = Platform.pathSeparator;
    final pendiente = File('${soporte.path}$separador$_pendiente');
    if (!pendiente.existsSync()) return false;
    final temporal = Directory('${soporte.path}${separador}restaurando');
    try {
      await _extraer(pendiente, temporal);
    } on FormatException {
      await _descartar(pendiente, temporal);
      return false;
    } on FileSystemException {
      await _descartar(pendiente, temporal);
      return false;
      // A truncated entry can fail inside the inflater with a RangeError.
    } on RangeError {
      await _descartar(pendiente, temporal);
      return false;
    }
    // Only with everything extracted is the current data set aside; it
    // comes back if the new one can't be put in place.
    final ruta = '${soporte.path}$separador';
    final actuales = [
      for (final sufijo in ['', '-wal', '-shm'])
        if (File('$ruta$nombreBase$sufijo').existsSync())
          File('$ruta$nombreBase$sufijo'),
      if (Directory('$ruta$carpetaImagenes').existsSync())
        Directory('$ruta$carpetaImagenes'),
    ];
    final apartados = <FileSystemEntity>[];
    try {
      for (final actual in actuales) {
        apartados.add(await actual.rename('${actual.path}$_apartado'));
      }
      await File('${temporal.path}$separador$nombreBase')
          .rename('$ruta$nombreBase');
      final nuevas = Directory('${temporal.path}$separador$carpetaImagenes');
      if (nuevas.existsSync()) await nuevas.rename('$ruta$carpetaImagenes');
    } on FileSystemException {
      await _reponer(apartados, ruta);
      await _descartar(pendiente, temporal);
      return false;
    }
    for (final apartado in apartados) {
      await apartado.delete(recursive: true);
    }
    await temporal.delete(recursive: true);
    await pendiente.delete();
    return true;
  }

  static const _apartado = '.anterior';

  /// Puts the set-aside data back where it was.
  static Future<void> _reponer(
    List<FileSystemEntity> apartados,
    String ruta,
  ) async {
    final base = File('$ruta$nombreBase');
    if (base.existsSync()) await base.delete();
    final imagenes = Directory('$ruta$carpetaImagenes');
    if (imagenes.existsSync()) await imagenes.delete(recursive: true);
    for (final apartado in apartados) {
      await apartado.rename(
        apartado.path.substring(0, apartado.path.length - _apartado.length),
      );
    }
  }

  static Future<void> _extraer(File pendiente, Directory temporal) async {
    final separador = Platform.pathSeparator;
    if (temporal.existsSync()) await temporal.delete(recursive: true);
    final zip = ZipDecoder().decodeBytes(await pendiente.readAsBytes());
    if (zip.findFile(nombreBase) == null) {
      throw const FormatException('El respaldo no trae la base de datos');
    }
    for (final entrada in zip.files) {
      if (!entrada.isFile || entrada.name == _manifiesto) continue;
      final partes = entrada.name.split('/');
      // A name that climbs out of the folder was not written by us.
      if (partes.any((p) => p.isEmpty || p == '..' || p.contains(':'))) {
        throw FormatException('Nombre no válido: ${entrada.name}');
      }
      final destino = File(
        '${temporal.path}$separador${partes.join(separador)}',
      );
      final contenido = entrada.content;
      // The library does not check it: a damaged entry is caught here.
      if (entrada.crc32 case final esperado?
          when getCrc32(contenido) != esperado) {
        throw FormatException('Dañado: ${entrada.name}');
      }
      await destino.parent.create(recursive: true);
      await destino.writeAsBytes(contenido, flush: true);
    }
  }

  static Future<void> _descartar(File pendiente, Directory temporal) async {
    if (temporal.existsSync()) await temporal.delete(recursive: true);
    await pendiente.rename(
      '${pendiente.parent.path}${Platform.pathSeparator}$fallido',
    );
  }
}
