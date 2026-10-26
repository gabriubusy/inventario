import 'package:inventario/features/productos/domain/producto.dart';

sealed class ResultadoEntrada {
  const ResultadoEntrada();
}

class EntradaRegistrada extends ResultadoEntrada {
  const EntradaRegistrada(this.producto);

  /// The product as it is after the entry.
  final Producto producto;
}

/// The product was removed while the window was open.
class ProductoNoEncontrado extends ResultadoEntrada {
  const ProductoNoEncontrado();
}
