import 'package:drift/drift.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/features/configuracion/domain/datos_negocio.dart';
import 'package:inventario/features/configuracion/domain/repositorio_negocio.dart';

class RepositorioNegocioDrift implements RepositorioNegocio {
  RepositorioNegocioDrift(this._db);

  static const _unico = 1;

  final BaseDatos _db;

  @override
  Future<DatosNegocio> leer() async {
    final fila = await (_db.select(
      _db.negocio,
    )..where((t) => t.id.equals(_unico))).getSingleOrNull();
    if (fila == null) return const DatosNegocio();
    return DatosNegocio(
      nombre: fila.nombre,
      rif: fila.rif,
      direccion: fila.direccion,
      telefono: fila.telefono,
    );
  }

  @override
  Future<void> guardar(DatosNegocio datos) => _db
      .into(_db.negocio)
      .insertOnConflictUpdate(
        NegocioCompanion.insert(
          id: const Value(_unico),
          nombre: datos.nombre,
          rif: datos.rif,
          direccion: datos.direccion,
          telefono: datos.telefono,
        ),
      );
}
