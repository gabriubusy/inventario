import 'package:drift/drift.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/app/base_datos/nuevo_id.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/incidencias/domain/datos_incidencia.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/repositorio_incidencias.dart';

class RepositorioIncidenciasDrift implements RepositorioIncidencias {
  RepositorioIncidenciasDrift(this._db);

  final BaseDatos _db;

  @override
  Future<List<Incidencia>> obtenerTodas() async {
    final filas = await (_db.select(
      _db.incidencias,
    )..orderBy([(t) => OrderingTerm(expression: t.rowId)])).get();
    return [for (final fila in filas) _aIncidencia(fila)];
  }

  @override
  Future<Incidencia> crear(DatosIncidencia datos) async {
    final incidencia = Incidencia.desde(nuevoId('i'), datos);
    await _db.into(_db.incidencias).insert(_fila(incidencia));
    return incidencia;
  }

  @override
  Future<void> actualizar(Incidencia incidencia) => (_db.update(
    _db.incidencias,
  )..where((t) => t.id.equals(incidencia.id))).write(_fila(incidencia));

  @override
  Future<void> borrar(String id) =>
      (_db.delete(_db.incidencias)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    final clave = normalizarParaBusqueda(anterior);
    await _db.transaction(() async {
      for (final fila in await _db.select(_db.incidencias).get()) {
        if (normalizarParaBusqueda(fila.proveedor) != clave) continue;
        await (_db.update(_db.incidencias)..where((t) => t.id.equals(fila.id)))
            .write(IncidenciasCompanion(proveedor: Value(nuevo)));
      }
    });
  }

  /// Example incidents with their own ids, for a first run while developing.
  Future<void> sembrar(List<Incidencia> incidencias) => _db.batch(
    (lote) => lote.insertAll(_db.incidencias, incidencias.map(_fila)),
  );

  IncidenciasCompanion _fila(Incidencia i) => IncidenciasCompanion.insert(
    id: i.id,
    fecha: i.fecha,
    proveedor: i.proveedor,
    productoId: i.productoId,
    producto: i.producto,
    forma: i.forma,
    marca: i.marca,
    tipo: i.tipo,
    piezas: i.piezas,
    cantidad: i.cantidad,
    nota: i.nota,
    sacada: i.sacada,
    respuesta: Value(i.respuesta),
  );

  Incidencia _aIncidencia(FilaIncidencia f) => Incidencia(
    id: f.id,
    fecha: f.fecha,
    proveedor: f.proveedor,
    productoId: f.productoId,
    producto: f.producto,
    forma: f.forma,
    marca: f.marca,
    tipo: f.tipo,
    piezas: f.piezas,
    cantidad: f.cantidad,
    nota: f.nota,
    sacada: f.sacada,
    respuesta: f.respuesta,
  );
}
