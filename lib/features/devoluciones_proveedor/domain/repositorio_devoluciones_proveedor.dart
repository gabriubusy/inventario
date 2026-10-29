import 'package:inventario/features/devoluciones_proveedor/domain/devolucion_proveedor.dart';

abstract interface class RepositorioDevolucionesProveedor {
  Future<List<DevolucionProveedor>> obtenerTodas();

  /// Stores it and returns it with its new id.
  Future<DevolucionProveedor> crear(DevolucionProveedor devolucion);

  /// Only to undo one just made.
  Future<void> borrar(String id);

  /// Writes when the goods were brought again.
  Future<void> actualizar(DevolucionProveedor devolucion);

  Future<void> renombrarProveedor(String anterior, String nuevo);
}
