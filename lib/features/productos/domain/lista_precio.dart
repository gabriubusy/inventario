/// The price lists. Detal is each brand's own price; the others follow a
/// rule per product ([ReglaPrecio]) and fall back to Detal without one.
enum ListaPrecio {
  detal('Detal'),
  mayor('Mayor'),
  especial('Especial');

  const ListaPrecio(this.etiqueta);

  final String etiqueta;

  /// The lists a product can set a rule for.
  static const conRegla = [mayor, especial];

  /// Alt+L in the sale window goes round them.
  ListaPrecio get siguiente => values[(index + 1) % values.length];
}
