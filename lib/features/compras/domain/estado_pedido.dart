/// Where a supplier order stands. The goods only enter the stock once
/// their arrival is confirmed, so an order lives on after it is placed.
enum EstadoPedido {
  pendiente('Pendiente'),
  parcial('Parcial'),
  recibido('Recibido'),
  conDiferencias('Recibido con diferencias');

  const EstadoPedido(this.etiqueta);

  final String etiqueta;

  /// Goods are still on the way.
  bool get esperando => this == pendiente || this == parcial;
}
