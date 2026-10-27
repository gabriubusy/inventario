sealed class ResultadoDevolucion {
  const ResultadoDevolucion();
}

class DevolucionRegistrada extends ResultadoDevolucion {
  const DevolucionRegistrada({required this.importe});

  /// Dollar hundredths handed back; null when the sale had no price.
  final int? importe;
}

/// More than what is left of the sale, or the sale was cancelled.
class DevolucionExcede extends ResultadoDevolucion {
  const DevolucionExcede();
}

/// The product was removed meanwhile.
class DevolucionSinProducto extends ResultadoDevolucion {
  const DevolucionSinProducto();
}
