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

/// The product was removed, so there is nowhere to put the goods back.
class AnulacionSinProducto extends ResultadoAnulacion {
  const AnulacionSinProducto();
}
