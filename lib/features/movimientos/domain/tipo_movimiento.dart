/// What moved the stock; mermas join when F3 is built.
enum TipoMovimiento {
  venta('Venta'),
  entrada('Entrada');

  const TipoMovimiento(this.etiqueta);

  final String etiqueta;
}
