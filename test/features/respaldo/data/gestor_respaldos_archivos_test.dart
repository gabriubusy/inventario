import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/features/configuracion/data/repositorio_negocio_drift.dart';
import 'package:inventario/features/configuracion/domain/datos_negocio.dart';
import 'package:inventario/features/respaldo/data/gestor_respaldos_archivos.dart';
import 'package:inventario/features/respaldo/domain/resultado_respaldo.dart';

void main() {
  late Directory soporte;
  late Directory pendrive;
  late File base;

  setUp(() async {
    soporte = await Directory.systemTemp.createTemp('soporte');
    pendrive = await Directory.systemTemp.createTemp('pendrive');
    base = File('${soporte.path}/${GestorRespaldosArchivos.nombreBase}');
    final imagenes = Directory('${soporte.path}/imagenes')..createSync();
    File('${imagenes.path}/foto.jpg').writeAsBytesSync([1, 2, 3]);
  });

  tearDown(() async {
    await soporte.delete(recursive: true);
    await pendrive.delete(recursive: true);
  });

  Future<T> conBase<T>(Future<T> Function(BaseDatos db) uso) async {
    final db = BaseDatos(NativeDatabase(base));
    try {
      return await uso(db);
    } finally {
      await db.close();
    }
  }

  test('a backup lands in the folder with a dated name', () async {
    final resultado = await conBase(
      (db) => GestorRespaldosArchivos(
        db,
        soporte,
      ).respaldar(pendrive.path, fecha: DateTime(2026, 10, 29, 15, 12)),
    );
    expect(resultado, isA<RespaldoGuardado>());
    expect(
      File('${pendrive.path}/inventario 2026-10-29 151200.inventario')
          .existsSync(),
      isTrue,
    );
  });

  test('two backups in the same second do not overwrite each other', () async {
    final fecha = DateTime(2026, 10, 29, 15, 12);
    final rutas = await conBase((db) async {
      final gestor = GestorRespaldosArchivos(db, soporte);
      final a = await gestor.respaldar(pendrive.path, fecha: fecha);
      final b = await gestor.respaldar(pendrive.path, fecha: fecha);
      return {(a as RespaldoGuardado).ruta, (b as RespaldoGuardado).ruta};
    });
    expect(rutas, hasLength(2));
  });

  test(
    'a broken pending backup leaves the data and lets the app start',
    () async {
      await conBase(
        (db) =>
            RepositorioNegocioDrift(db)
                .guardar(const DatosNegocio(nombre: 'La Esquina')),
      );
      File('${soporte.path}/restaurar.inventario').writeAsStringSync('roto');
      expect(
        await GestorRespaldosArchivos.aplicarRestauracionPendiente(soporte),
        isFalse,
      );
      expect(
        (await conBase((db) => RepositorioNegocioDrift(db).leer())).nombre,
        'La Esquina',
      );
      expect(File('${soporte.path}/imagenes/foto.jpg').existsSync(), isTrue);
      expect(
        File('${soporte.path}/${GestorRespaldosArchivos.fallido}').existsSync(),
        isTrue,
      );
      expect(
        await GestorRespaldosArchivos.aplicarRestauracionPendiente(soporte),
        isFalse,
      );
    },
  );

  test('a missing folder is said, not an error', () async {
    final resultado = await conBase(
      (db) => GestorRespaldosArchivos(
        db,
        soporte,
      ).respaldar('${pendrive.path}/no-existe', fecha: DateTime(2026)),
    );
    expect(resultado, isA<CarpetaNoDisponible>());
  });

  test('restoring brings back the data and photos of the backup', () async {
    const antes = DatosNegocio(nombre: 'La Esquina');
    final guardado = await conBase((db) async {
      await RepositorioNegocioDrift(db).guardar(antes);
      return GestorRespaldosArchivos(
        db,
        soporte,
      ).respaldar(pendrive.path, fecha: DateTime(2026, 10, 20, 18, 5));
    });
    final ruta = (guardado as RespaldoGuardado).ruta;

    // Things change after the backup...
    File('${soporte.path}/imagenes/foto.jpg').deleteSync();
    final preparada = await conBase((db) async {
      await RepositorioNegocioDrift(db)
          .guardar(const DatosNegocio(nombre: 'Otro nombre'));
      return GestorRespaldosArchivos(
        db,
        soporte,
      ).prepararRestauracion(ruta, fecha: DateTime(2026, 10, 29, 15, 12));
    });
    expect(preparada, isA<RestauracionPreparada>());
    expect(
      File((preparada as RestauracionPreparada).copiaDeAntes).existsSync(),
      isTrue,
    );

    // ...and the next start puts the backup back.
    expect(
      await GestorRespaldosArchivos.aplicarRestauracionPendiente(soporte),
      isTrue,
    );
    expect(await conBase((db) => RepositorioNegocioDrift(db).leer()), antes);
    expect(File('${soporte.path}/imagenes/foto.jpg').readAsBytesSync(), [
      1,
      2,
      3,
    ]);
    expect(
      await GestorRespaldosArchivos.aplicarRestauracionPendiente(soporte),
      isFalse,
    );
  });

  /// The encoder here always writes '/', but a zip from another tool can
  /// store '\' in a name, so those bytes go in by hand.
  List<int> respaldoConEntrada(String nombre) {
    final hueco = 'x' * nombre.length;
    final zip = Archive()
      ..addFile(
        ArchiveFile.bytes(
          GestorRespaldosArchivos.nombreBase,
          Uint8List.fromList([1]),
        ),
      )
      ..addFile(ArchiveFile.bytes(hueco, Uint8List.fromList([9])));
    final bytes = ZipEncoder().encode(zip);
    final buscado = ascii.encode(hueco);
    final puesto = ascii.encode(nombre);
    for (var i = 0; i + buscado.length <= bytes.length; i++) {
      if (!_empiezaEn(bytes, i, buscado)) continue;
      bytes.setRange(i, i + puesto.length, puesto);
    }
    return bytes;
  }

  /// A backup that someone else prepared can name its entries whatever it
  /// likes; none of them may land outside the restore folder.
  test(
    'a backup with a name that climbs out of the folder is refused',
    () async {
      final fuera = File('${soporte.parent.path}/fuera.txt');
      if (fuera.existsSync()) fuera.deleteSync();
      for (final nombre in [
        r'..\..\fuera.txt',
        '../../fuera.txt',
        r'imagenes\..\..\fuera.txt',
        r'\fuera.txt',
      ]) {
        File('${soporte.path}/restaurar.inventario')
            .writeAsBytesSync(respaldoConEntrada(nombre));

        expect(
          await GestorRespaldosArchivos.aplicarRestauracionPendiente(soporte),
          isFalse,
          reason: nombre,
        );
        expect(fuera.existsSync(), isFalse, reason: nombre);
        expect(File('${soporte.path}/fuera.txt').existsSync(), isFalse);
        File('${soporte.path}/${GestorRespaldosArchivos.fallido}').deleteSync();
      }
    },
  );

  test('a file that is not a backup is refused', () async {
    final otro = File('${pendrive.path}/notas.inventario')
      ..writeAsStringSync('hola');
    final resultado = await conBase(
      (db) => GestorRespaldosArchivos(
        db,
        soporte,
      ).prepararRestauracion(otro.path, fecha: DateTime(2026)),
    );
    expect(resultado, isA<RespaldoNoValido>());
  });
}

bool _empiezaEn(List<int> bytes, int desde, List<int> buscado) {
  for (var j = 0; j < buscado.length; j++) {
    if (bytes[desde + j] != buscado[j]) return false;
  }
  return true;
}
