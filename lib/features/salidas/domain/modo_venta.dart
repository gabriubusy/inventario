/// How a product counted in pieces and kilos leaves the shop.
enum ModoVenta {
  /// The whole piece is weighed: one piece and its real weight go out.
  piezaEntera('Pieza entera', 'se pesa la pieza'),

  /// Sold by weight from an open piece; opens one if none is open.
  porPeso('Por kilo', 'de una pieza abierta');

  const ModoVenta(this.etiqueta, this.detalle);

  final String etiqueta;
  final String detalle;
}
