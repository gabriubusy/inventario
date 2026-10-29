import 'package:drift/drift.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/app/base_datos/nuevo_id.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';
import 'package:inventario/features/salidas/domain/repositorio_ventas.dart';
import 'package:inventario/features/salidas/domain/venta.dart';

class RepositorioVentasDrift implements RepositorioVentas {
  RepositorioVentasDrift(this._db);

  final BaseDatos _db;

  @override
  Future<List<Venta>> obtenerTodas() async {
    final filas = await (_db.select(
      _db.ventas,
    )..orderBy([(t) => OrderingTerm(expression: t.fecha)])).get();
    final pagos = await (_db.select(
      _db.pagosVenta,
    )..orderBy([(t) => OrderingTerm(expression: t.orden)])).get();
    return [
      for (final fila in filas)
        Venta(
          id: fila.id,
          fecha: fila.fecha,
          total: fila.total,
          tasa: fila.tasa,
          lista: fila.lista,
          pagos: List.unmodifiable([
            for (final p in pagos)
              if (p.ventaId == fila.id)
                PagoVenta(
                  medio: p.medio,
                  monto: p.monto,
                  referencia: p.referencia,
                ),
          ]),
        ),
    ];
  }

  @override
  Future<Venta> registrar(Venta venta) => _db.transaction(() async {
    final guardada = venta.conId(nuevoId('t'));
    await _db
        .into(_db.ventas)
        .insert(
          VentasCompanion.insert(
            id: guardada.id,
            fecha: guardada.fecha,
            total: guardada.total,
            tasa: Value(guardada.tasa),
            lista: Value(guardada.lista),
          ),
        );
    await _db.batch(
      (lote) => lote.insertAll(_db.pagosVenta, [
        for (final (orden, p) in guardada.pagos.indexed)
          PagosVentaCompanion.insert(
            ventaId: guardada.id,
            orden: orden,
            medio: p.medio,
            monto: p.monto,
            referencia: p.referencia,
          ),
      ]),
    );
    return guardada;
  });

  @override
  Future<void> quitar(String id) =>
      (_db.delete(_db.ventas)..where((t) => t.id.equals(id))).go();
}
