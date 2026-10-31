import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/base_datos/base_datos.dart';

void main() {
  late Directory carpeta;

  setUp(() async => carpeta = await Directory.systemTemp.createTemp('migra'));
  tearDown(() => carpeta.delete(recursive: true));

  test('a database from version 2 opens and reaches today\'s tables', () async {
    final archivo = File('${carpeta.path}/v2.sqlite');
    // Today's tables trimmed back to what version 2 had.
    final nueva = BaseDatos(NativeDatabase(archivo));
    await nueva.customStatement('SELECT 1');
    for (final tabla in [
      'pagos_venta',
      'ventas',
      'cajas',
      'gastos',
      'lineas_devolucion',
      'devoluciones_proveedor',
      'negocio',
      'reglas_precio',
    ]) {
      await nueva.customStatement('DROP TABLE $tabla');
    }
    await nueva.customStatement('DROP INDEX IF EXISTS ventas_fecha');
    await nueva.customStatement('ALTER TABLE movimientos DROP COLUMN venta_id');
    await nueva.customStatement(
      'ALTER TABLE movimientos DROP COLUMN medio_reembolso',
    );
    await nueva.customStatement(
      'ALTER TABLE movimientos DROP COLUMN anulada_el',
    );
    await nueva.customStatement('PRAGMA user_version = 2');
    await nueva.close();

    final vieja = BaseDatos(NativeDatabase(archivo));
    addTearDown(vieja.close);
    await vieja.customSelect('SELECT lista FROM ventas').get();
    await vieja.customSelect('SELECT venta_id FROM movimientos').get();
    final indices = await vieja
        .customSelect(
          "SELECT name FROM sqlite_master WHERE name = 'ventas_fecha'",
        )
        .get();
    expect(indices, hasLength(1));
  });
}
