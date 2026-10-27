import 'package:drift/drift.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/app/base_datos/nuevo_id.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/compras/domain/pago.dart';
import 'package:inventario/features/compras/domain/repositorio_compras.dart';

class RepositorioComprasDrift implements RepositorioCompras {
  RepositorioComprasDrift(this._db);

  final BaseDatos _db;

  @override
  Future<List<Compra>> obtenerCompras() async {
    final filas = await _db.select(_db.compras).get();
    final lineas = await (_db.select(
      _db.lineasCompra,
    )..orderBy([(t) => OrderingTerm(expression: t.orden)])).get();
    final porCompra = <String, List<LineaCompra>>{};
    for (final l in lineas) {
      (porCompra[l.compraId] ??= []).add(
        LineaCompra(
          productoId: l.productoId,
          producto: l.producto,
          forma: l.forma,
          marca: l.marca,
          piezas: l.piezas,
          cantidad: l.cantidad,
          costo: l.costo,
        ),
      );
    }
    return [
      for (final f in filas)
        Compra(
          id: f.id,
          fecha: f.fecha,
          proveedor: f.proveedor,
          factura: f.factura,
          lineas: porCompra[f.id] ?? const [],
          vence: f.vence,
          medio: f.medio,
          tasa: f.tasa,
        ),
    ];
  }

  @override
  Future<List<Pago>> obtenerPagos() async {
    final filas = await _db.select(_db.pagos).get();
    return [
      for (final f in filas)
        Pago(
          id: f.id,
          compraId: f.compraId,
          fecha: f.fecha,
          medio: f.medio,
          monto: f.monto,
          entregado: f.entregado,
          tasa: f.tasa,
          referencia: f.referencia,
        ),
    ];
  }

  @override
  Future<Compra> crearCompra(Compra compra) async {
    final guardada = compra.conId(nuevoId('c'));
    await _db.transaction(() async {
      await _db
          .into(_db.compras)
          .insert(
            ComprasCompanion.insert(
              id: guardada.id,
              fecha: guardada.fecha,
              proveedor: guardada.proveedor,
              factura: guardada.factura,
              vence: Value(guardada.vence),
              medio: Value(guardada.medio),
              tasa: Value(guardada.tasa),
            ),
          );
      for (final (i, l) in guardada.lineas.indexed) {
        await _db
            .into(_db.lineasCompra)
            .insert(
              LineasCompraCompanion.insert(
                compraId: guardada.id,
                orden: i,
                productoId: l.productoId,
                producto: l.producto,
                forma: l.forma,
                marca: l.marca,
                piezas: l.piezas,
                cantidad: l.cantidad,
                costo: l.costo,
              ),
            );
      }
    });
    return guardada;
  }

  @override
  Future<void> borrarCompra(String id) =>
      (_db.delete(_db.compras)..where((t) => t.id.equals(id))).go();

  @override
  Future<Pago> crearPago(Pago pago) async {
    final guardado = pago.conId(nuevoId('p'));
    await _db
        .into(_db.pagos)
        .insert(
          PagosCompanion.insert(
            id: guardado.id,
            compraId: guardado.compraId,
            fecha: guardado.fecha,
            medio: guardado.medio,
            monto: guardado.monto,
            entregado: guardado.entregado,
            tasa: Value(guardado.tasa),
            referencia: guardado.referencia,
          ),
        );
    return guardado;
  }

  @override
  Future<void> borrarPago(String id) =>
      (_db.delete(_db.pagos)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    final clave = normalizarParaBusqueda(anterior);
    await _db.transaction(() async {
      for (final fila in await _db.select(_db.compras).get()) {
        if (normalizarParaBusqueda(fila.proveedor) != clave) continue;
        await (_db.update(_db.compras)..where((t) => t.id.equals(fila.id)))
            .write(ComprasCompanion(proveedor: Value(nuevo)));
      }
    });
  }
}
