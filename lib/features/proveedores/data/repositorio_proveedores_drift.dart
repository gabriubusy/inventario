import 'package:drift/drift.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/app/base_datos/nuevo_id.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/proveedores/domain/datos_proveedor.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/domain/repositorio_proveedores.dart';
import 'package:inventario/features/proveedores/domain/resultado_guardar_proveedor.dart';

class RepositorioProveedoresDrift implements RepositorioProveedores {
  RepositorioProveedoresDrift(this._db);

  final BaseDatos _db;

  @override
  Future<List<Proveedor>> obtenerTodos() async {
    final filas = await (_db.select(
      _db.proveedores,
    )..orderBy([(t) => OrderingTerm(expression: t.rowId)])).get();
    return [for (final fila in filas) _aProveedor(fila)];
  }

  @override
  Future<ResultadoGuardarProveedor> crear(DatosProveedor datos) =>
      _db.transaction(() async {
        if (await _nombreUsado(datos.nombre)) {
          return const NombreProveedorRepetido();
        }
        final id = nuevoId('v');
        await _db.into(_db.proveedores).insert(_fila(id, datos));
        return ProveedorGuardado(_desde(id, datos));
      });

  @override
  Future<ResultadoGuardarProveedor> actualizar(
    String id,
    DatosProveedor datos,
  ) => _db.transaction(() async {
    if (await _nombreUsado(datos.nombre, salvo: id)) {
      return const NombreProveedorRepetido();
    }
    await (_db.update(
      _db.proveedores,
    )..where((t) => t.id.equals(id))).write(_fila(id, datos));
    return ProveedorGuardado(_desde(id, datos));
  });

  /// Example suppliers with their own ids, for a first run while developing.
  Future<void> sembrar(List<Proveedor> proveedores) => _db.batch((lote) {
    lote.insertAll(_db.proveedores, [
      for (final p in proveedores)
        _fila(
          p.id,
          DatosProveedor(
            nombre: p.nombre,
            rif: p.rif,
            telefono: p.telefono,
            contacto: p.contacto,
            notas: p.notas,
          ),
        ),
    ]);
  });

  Future<bool> _nombreUsado(String nombre, {String? salvo}) async {
    final consulta = _db.select(_db.proveedores)
      ..where((t) => t.nombreClave.equals(normalizarParaBusqueda(nombre)));
    if (salvo != null) consulta.where((t) => t.id.equals(salvo).not());
    return (await consulta.get()).isNotEmpty;
  }

  ProveedoresCompanion _fila(String id, DatosProveedor datos) =>
      ProveedoresCompanion.insert(
        id: id,
        nombre: datos.nombre,
        nombreClave: normalizarParaBusqueda(datos.nombre),
        rif: datos.rif,
        telefono: datos.telefono,
        contacto: datos.contacto,
        notas: datos.notas,
      );

  Proveedor _desde(String id, DatosProveedor datos) => Proveedor(
    id: id,
    nombre: datos.nombre,
    rif: datos.rif,
    telefono: datos.telefono,
    contacto: datos.contacto,
    notas: datos.notas,
  );

  Proveedor _aProveedor(FilaProveedor fila) => Proveedor(
    id: fila.id,
    nombre: fila.nombre,
    rif: fila.rif,
    telefono: fila.telefono,
    contacto: fila.contacto,
    notas: fila.notas,
  );
}
