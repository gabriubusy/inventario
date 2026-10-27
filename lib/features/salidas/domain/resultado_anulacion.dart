sealed class ResultadoAnulacion {
  const ResultadoAnulacion();
}

class VentaAnulada extends ResultadoAnulacion {
  const VentaAnulada();
}

/// It was cancelled before, so its goods are already back.
class YaAnulada extends ResultadoAnulacion {
  const YaAnulada();
}

/// Part of it was already returned by the customer; cancelling it all
/// would put those goods back twice.
class AnulacionConDevolucion extends ResultadoAnulacion {
  const AnulacionConDevolucion();
}

/// The product was removed, so there is nowhere to put the goods back.
class AnulacionSinProducto extends ResultadoAnulacion {
  const AnulacionSinProducto();
}
