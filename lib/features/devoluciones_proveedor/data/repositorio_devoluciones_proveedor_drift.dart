import 'package:drift/drift.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/app/base_datos/nuevo_id.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/devolucion_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/repositorio_devoluciones_proveedor.dart';

class RepositorioDevolucionesProveedorDrift
    implements RepositorioDevolucionesProveedor {
  RepositorioDevolucionesProveedorDrift(this._db);

  final BaseDatos _db;

  @override
  Future<List<DevolucionProveedor>> obtenerTodas() async {
    final filas = await _db.select(_db.devolucionesProveedor).get();
    final lineas = await (_db.select(
      _db.lineasDevolucion,
    )..orderBy([(t) => OrderingTerm(expression: t.orden)])).get();
    final porDevolucion = <String, List<LineaCompra>>{};
    for (final l in lineas) {
      (porDevolucion[l.devolucionId] ??= []).add(
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
        DevolucionProveedor(
          id: f.id,
          fecha: f.fecha,
          proveedor: f.proveedor,
          motivo: f.motivo,
          lineas: porDevolucion[f.id] ?? const [],
          compensacion: f.compensacion,
          compraId: f.compraId,
          medio: f.medio,
          entregado: f.entregado,
          tasa: f.tasa,
          repuesta: f.repuesta,
          nota: f.nota,
          incidenciaId: f.incidenciaId,
          sacada: f.sacada,
        ),
    ];
  }

  @override
  Future<DevolucionProveedor> crear(DevolucionProveedor devolucion) async {
    final guardada = devolucion.conId(nuevoId('d'));
    await _db.transaction(() async {
      await _db
          .into(_db.devolucionesProveedor)
          .insert(
            DevolucionesProveedorCompanion.insert(
              id: guardada.id,
              fecha: guardada.fecha,
              proveedor: guardada.proveedor,
              motivo: guardada.motivo,
              compensacion: guardada.compensacion,
              compraId: Value(guardada.compraId),
              medio: Value(guardada.medio),
              entregado: Value(guardada.entregado),
              tasa: Value(guardada.tasa),
              repuesta: Value(guardada.repuesta),
              nota: guardada.nota,
              incidenciaId: Value(guardada.incidenciaId),
              sacada: guardada.sacada,
            ),
          );
      for (final (i, l) in guardada.lineas.indexed) {
        await _db
            .into(_db.lineasDevolucion)
            .insert(
              LineasDevolucionCompanion.insert(
                devolucionId: guardada.id,
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
  Future<void> borrar(String id) => (_db.delete(
    _db.devolucionesProveedor,
  )..where((t) => t.id.equals(id))).go();

  @override
  Future<void> actualizar(DevolucionProveedor devolucion) =>
      (_db.update(
        _db.devolucionesProveedor,
      )..where((t) => t.id.equals(devolucion.id))).write(
        DevolucionesProveedorCompanion(repuesta: Value(devolucion.repuesta)),
      );

  @override
  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    final clave = normalizarParaBusqueda(anterior);
    await _db.transaction(() async {
      for (final fila in await _db.select(_db.devolucionesProveedor).get()) {
        if (normalizarParaBusqueda(fila.proveedor) != clave) continue;
        await (_db.update(_db.devolucionesProveedor)
              ..where((t) => t.id.equals(fila.id)))
            .write(DevolucionesProveedorCompanion(proveedor: Value(nuevo)));
      }
    });
  }
}
