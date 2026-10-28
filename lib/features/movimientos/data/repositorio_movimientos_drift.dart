import 'package:drift/drift.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/app/base_datos/nuevo_id.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/repositorio_movimientos.dart';

class RepositorioMovimientosDrift implements RepositorioMovimientos {
  RepositorioMovimientosDrift(this._db);

  final BaseDatos _db;

  @override
  Future<List<Movimiento>> obtenerTodos() async {
    final filas = await (_db.select(
      _db.movimientos,
    )..orderBy([(t) => OrderingTerm(expression: t.fecha)])).get();
    return [for (final fila in filas) _aMovimiento(fila)];
  }

  @override
  Future<Movimiento> anotar(Movimiento movimiento) async {
    final guardado = movimiento.conId(nuevoId('m'));
    await _db.into(_db.movimientos).insert(_fila(guardado));
    return guardado;
  }

  @override
  Future<void> quitar(String id) =>
      (_db.delete(_db.movimientos)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> anular(String id) =>
      (_db.update(_db.movimientos)..where((t) => t.id.equals(id))).write(
        const MovimientosCompanion(anulada: Value(true)),
      );

  /// Example history with its own ids, for a first run while developing.
  Future<void> sembrar(List<Movimiento> movimientos) => _db.batch(
    (lote) => lote.insertAll(_db.movimientos, movimientos.map(_fila)),
  );

  MovimientosCompanion _fila(Movimiento m) => MovimientosCompanion.insert(
    id: m.id,
    fecha: m.fecha,
    tipo: m.tipo,
    productoId: m.productoId,
    producto: m.producto,
    forma: m.forma,
    marca: m.marca,
    proveedor: m.proveedor,
    piezas: m.piezas,
    cantidad: m.cantidad,
    importe: Value(m.importe),
    costo: Value(m.costo),
    abrioPieza: m.abrioPieza,
    anulada: m.anulada,
    tasa: Value(m.tasa),
    nota: m.nota,
    origenId: Value(m.origenId),
    ventaId: Value(m.ventaId),
    medioReembolso: Value(m.medioReembolso),
  );

  Movimiento _aMovimiento(FilaMovimiento f) => Movimiento(
    id: f.id,
    fecha: f.fecha,
    tipo: f.tipo,
    productoId: f.productoId,
    producto: f.producto,
    forma: f.forma,
    marca: f.marca,
    proveedor: f.proveedor,
    piezas: f.piezas,
    cantidad: f.cantidad,
    importe: f.importe,
    costo: f.costo,
    abrioPieza: f.abrioPieza,
    anulada: f.anulada,
    tasa: f.tasa,
    nota: f.nota,
    origenId: f.origenId,
    ventaId: f.ventaId,
    medioReembolso: f.medioReembolso,
  );
}
