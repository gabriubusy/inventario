/// What was physically counted for one brand lot; already validated.
class ConteoLote {
  const ConteoLote({
    required this.productoId,
    required this.marca,
    this.proveedor = '',
    this.piezas,
    required this.cantidad,
  });

  final String productoId;
  final String marca;
  final String proveedor;

  /// Whole pieces counted; null for products not counted in pieces.
  final int? piezas;

  /// Scaled by the product's unit, like [LoteMarca.cantidad].
  final int cantidad;

  @override
  bool operator ==(Object other) =>
      other is ConteoLote &&
      other.productoId == productoId &&
      other.marca == marca &&
      other.proveedor == proveedor &&
      other.piezas == piezas &&
      other.cantidad == cantidad;

  @override
  int get hashCode =>
      Object.hash(productoId, marca, proveedor, piezas, cantidad);
}
