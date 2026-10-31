import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/pago.dart';

sealed class ResultadoCompra {
  const ResultadoCompra();
}

class CompraRegistrada extends ResultadoCompra {
  const CompraRegistrada(this.compra);

  final Compra compra;
}

/// A product on the invoice was removed while the window was open.
class CompraSinProducto extends ResultadoCompra {
  const CompraSinProducto(this.producto);

  final String producto;
}

/// Paid on the spot in bolívares without today's rate: the till could not
/// tell how much left.
class CompraSinTasa extends ResultadoCompra {
  const CompraSinTasa();
}

sealed class ResultadoPago {
  const ResultadoPago();
}

class PagoRegistrado extends ResultadoPago {
  const PagoRegistrado(this.pago, {required this.debe});

  final Pago pago;

  /// What is left to pay, in dollar hundredths.
  final int debe;
}

/// More than what is owed on that invoice.
class PagoExcede extends ResultadoPago {
  const PagoExcede({required this.debe});

  final int debe;
}

/// A payment in bolívares needs today's rate to know what it covers.
class PagoSinTasa extends ResultadoPago {
  const PagoSinTasa();
}
