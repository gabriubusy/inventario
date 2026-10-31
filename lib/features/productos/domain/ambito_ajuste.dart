import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// Which products a bulk price change touches.
sealed class AmbitoAjuste {
  const AmbitoAjuste();

  bool incluye(Producto producto);

  /// Which brands of an included product move their Detal price.
  bool incluyeLote(LoteMarca lote) => true;

  /// Mayor and Especial rules belong to the whole product, every brand.
  bool incluyeRegla(Producto producto) => incluye(producto);

  /// Packs have one price for every brand; only a whole-product scope moves it.
  bool get incluyePresentaciones => true;
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
  bool incluye(Producto producto) => producto.lotes.any(incluyeLote);

  /// Other suppliers' brands of the same product keep their price.
  @override
  bool incluyeLote(LoteMarca lote) =>
      normalizarParaBusqueda(lote.proveedor) ==
      normalizarParaBusqueda(proveedor);

  @override
  bool get incluyePresentaciones => false;

  /// A rule moves every brand's price, so only when all come from it.
  @override
  bool incluyeRegla(Producto producto) =>
      producto.lotes.isNotEmpty && producto.lotes.every(incluyeLote);

  @override
  bool operator ==(Object other) =>
      other is DeProveedor && other.proveedor == proveedor;

  @override
  int get hashCode => proveedor.hashCode;
}
