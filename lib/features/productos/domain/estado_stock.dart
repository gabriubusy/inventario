/// Declared from most to least urgent; lists sort by this order.
enum EstadoStock {
  agotado('Agotado'),
  bajo('Stock bajo'),
  disponible('Disponible');

  const EstadoStock(this.etiqueta);

  final String etiqueta;
}
