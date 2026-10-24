import 'package:inventario/features/productos/domain/producto.dart';

abstract interface class RepositorioProductos {
  Future<List<Producto>> obtenerTodos();
}
