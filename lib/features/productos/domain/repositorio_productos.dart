import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';

abstract interface class RepositorioProductos {
  Future<List<Producto>> obtenerTodos();

  Future<ResultadoGuardarProducto> crear(DatosProducto datos);

  Future<ResultadoGuardarProducto> actualizar(String id, DatosProducto datos);

  /// Keeps brand lots linked when a supplier changes its name.
  Future<void> renombrarProveedor(String anterior, String nuevo);
}
