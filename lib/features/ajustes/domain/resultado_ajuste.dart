import 'package:inventario/features/productos/domain/producto.dart';

sealed class ResultadoAjuste {
  const ResultadoAjuste();
}

class AjusteRegistrado extends ResultadoAjuste {
  const AjusteRegistrado(this.producto);

  /// The product as it is after the goods left.
  final Producto producto;
}

/// The stock changed while the window was open and no longer holds that
/// much of the brand, or the product is gone; nothing was saved.
class AjusteSinExistencias extends ResultadoAjuste {
  const AjusteSinExistencias();
}
