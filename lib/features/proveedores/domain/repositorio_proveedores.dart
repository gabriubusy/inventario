import 'package:inventario/features/proveedores/domain/datos_proveedor.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/domain/resultado_guardar_proveedor.dart';

abstract interface class RepositorioProveedores {
  Future<List<Proveedor>> obtenerTodos();

  Future<ResultadoGuardarProveedor> crear(DatosProveedor datos);

  Future<ResultadoGuardarProveedor> actualizar(String id, DatosProveedor datos);
}
