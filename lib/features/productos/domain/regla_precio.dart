/// How a product's price in Mayor or Especial is worked out.
sealed class ReglaPrecio {
  const ReglaPrecio();
}

/// The brand's cost plus a profit; [porcentaje] in hundredths of a percent
/// (3000 = 30 %).
class MargenSobreCosto extends ReglaPrecio {
  const MargenSobreCosto(this.porcentaje);

  final int porcentaje;

  @override
  bool operator ==(Object other) =>
      other is MargenSobreCosto && other.porcentaje == porcentaje;

  @override
  int get hashCode => Object.hash(MargenSobreCosto, porcentaje);
}

/// The same price for every brand, in dollar hundredths per kg, l or und.
class PrecioFijo extends ReglaPrecio {
  const PrecioFijo(this.precio);

  final int precio;

  @override
  bool operator ==(Object other) =>
      other is PrecioFijo && other.precio == precio;

  @override
  int get hashCode => Object.hash(PrecioFijo, precio);
}
