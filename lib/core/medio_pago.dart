/// The currency an amount is handed over in.
enum Moneda { dolares, bolivares }

/// How money changes hands, in sales and with suppliers. Each way implies
/// its currency, so paying takes one choice instead of two.
enum MedioPago {
  efectivoDolares('Efectivo \$', Moneda.dolares),
  efectivoBolivares('Efectivo Bs', Moneda.bolivares),
  pagoMovil('Pago móvil', Moneda.bolivares, conReferencia: true),
  puntoDeVenta('Punto de venta', Moneda.bolivares),
  transferencia('Transferencia', Moneda.bolivares, conReferencia: true),
  zelle('Zelle', Moneda.dolares, conReferencia: true);

  const MedioPago(this.etiqueta, this.moneda, {this.conReferencia = false});

  final String etiqueta;
  final Moneda moneda;

  /// Offers a field for the bank's reference number (always optional).
  final bool conReferencia;

  /// Only cash can be handed back as change.
  bool get esEfectivo => this == efectivoDolares || this == efectivoBolivares;

  /// A supplier is never paid through the shop's card terminal.
  static List<MedioPago> get paraProveedores =>
      values.where((m) => m != puntoDeVenta).toList();
}
