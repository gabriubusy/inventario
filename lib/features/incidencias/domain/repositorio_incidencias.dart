import 'package:inventario/features/incidencias/domain/datos_incidencia.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';

abstract interface class RepositorioIncidencias {
  Future<List<Incidencia>> obtenerTodas();

  Future<Incidencia> crear(DatosIncidencia datos);

  Future<void> actualizar(Incidencia incidencia);

  /// Only to undo a registration that was just made.
  Future<void> borrar(String id);

  Future<void> renombrarProveedor(String anterior, String nuevo);
}
