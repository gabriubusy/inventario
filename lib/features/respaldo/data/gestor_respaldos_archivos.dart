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
    final archivo = File(
      '${destino.path}${Platform.pathSeparator}'
      '${nombreRespaldo(fecha, prefijo: prefijo)}',
    );
    await archivo.writeAsBytes(bytes, flush: true);
    return RespaldoGuardado(ruta: archivo.path, bytes: bytes.length);
  }

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

  /// Run at start, before the database opens: puts a prepared backup in
  /// place of the database and the photos. True when it restored one.
  static Future<bool> aplicarRestauracionPendiente(Directory soporte) async {
    final separador = Platform.pathSeparator;
    final pendiente = File('${soporte.path}$separador$_pendiente');
    if (!pendiente.existsSync()) return false;
    final zip = ZipDecoder().decodeBytes(await pendiente.readAsBytes());
    for (final sufijo in ['', '-wal', '-shm']) {
      final viejo = File('${soporte.path}$separador$nombreBase$sufijo');
      if (viejo.existsSync()) await viejo.delete();
    }
    final imagenes = Directory('${soporte.path}$separador$carpetaImagenes');
    if (imagenes.existsSync()) await imagenes.delete(recursive: true);
    for (final entrada in zip.files) {
      if (!entrada.isFile || entrada.name == _manifiesto) continue;
      final destino = File(
        '${soporte.path}$separador${entrada.name.replaceAll('/', separador)}',
      );
      await destino.parent.create(recursive: true);
      await destino.writeAsBytes(entrada.content, flush: true);
    }
    await pendiente.delete();
    return true;
  }
}
