import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/repositorio_productos.dart';

/// Stand-in until local persistence is decided.
class RepositorioProductosEnMemoria implements RepositorioProductos {
  const RepositorioProductosEnMemoria(this._productos);

  final List<Producto> _productos;

  @override
  Future<List<Producto>> obtenerTodos() async => List.unmodifiable(_productos);
}
