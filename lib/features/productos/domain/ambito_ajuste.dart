import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// Which products a bulk price change touches.
sealed class AmbitoAjuste {
  const AmbitoAjuste();

  bool incluye(Producto producto);
}

class TodosLosProductos extends AmbitoAjuste {
  const TodosLosProductos();

  @override
  bool incluye(Producto producto) => true;

  @override
  bool operator ==(Object other) => other is TodosLosProductos;

  @override
  int get hashCode => (TodosLosProductos).hashCode;
}

class DeCategoria extends AmbitoAjuste {
  const DeCategoria(this.categoria);

  final Categoria categoria;

  @override
  bool incluye(Producto producto) => producto.categoria == categoria;

  @override
  bool operator ==(Object other) =>
      other is DeCategoria && other.categoria == categoria;

  @override
  int get hashCode => categoria.hashCode;
}

/// Products with at least one brand from [proveedor], matched by name.
class DeProveedor extends AmbitoAjuste {
  const DeProveedor(this.proveedor);

  final String proveedor;

  @override
  bool incluye(Producto producto) {
    final buscado = normalizarParaBusqueda(proveedor);
    return producto.lotes.any(
      (l) => normalizarParaBusqueda(l.proveedor) == buscado,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DeProveedor && other.proveedor == proveedor;

  @override
  int get hashCode => proveedor.hashCode;
}
