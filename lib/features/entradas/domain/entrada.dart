/// Goods received for one brand lot of a product; already validated.
class Entrada {
  const Entrada({
    required this.marca,
    this.proveedor = '',
    this.piezas = 0,
    required this.cantidad,
    this.nota = '',
  });

  final String marca;
  final String proveedor;

  /// Whole pieces received; 0 for products not counted in pieces.
  final int piezas;

  /// Scaled by the product's unit (grams for kg).
  final int cantidad;

  final String nota;

  @override
  bool operator ==(Object other) =>
      other is Entrada &&
      other.marca == marca &&
      other.proveedor == proveedor &&
      other.piezas == piezas &&
      other.cantidad == cantidad &&
      other.nota == nota;

  @override
  int get hashCode => Object.hash(marca, proveedor, piezas, cantidad, nota);
}
