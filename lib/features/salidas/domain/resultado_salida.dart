import 'package:inventario/features/productos/domain/producto.dart';

sealed class ResultadoSalida {
  const ResultadoSalida();
}

class SalidaRegistrada extends ResultadoSalida {
  const SalidaRegistrada(this.producto);

  /// The product as it is after the sale.
  final Producto producto;
}

/// The stock changed while the window was open and no longer covers it.
class SinExistencias extends ResultadoSalida {
  const SinExistencias();
}

/// Nothing is sold without today's rate, so the amount in Bs is right.
class SinTasaDelDia extends ResultadoSalida {
  const SinTasaDelDia();
}

/// The product was removed while the window was open.
class SalidaSinProducto extends ResultadoSalida {
  const SalidaSinProducto();
}
