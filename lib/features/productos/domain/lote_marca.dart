/// Stock of one brand from one supplier within a product.
class LoteMarca {
  const LoteMarca({
    required this.marca,
    this.proveedor = '',
    this.piezas = 0,
    this.piezaAbierta = false,
    required this.cantidad,
    this.precio,
    this.costo,
  });

  final String marca;
  final String proveedor;

  /// Whole pieces; always 0 for products not counted in pieces.
  final int piezas;

  /// A piece already started by a sale by weight.
  final bool piezaAbierta;

  /// Scaled by the product's unit (grams for kg), open piece included.
  final int cantidad;

  /// Selling price in dollar hundredths per kg, l or und; null if not set.
  /// Each brand has its own because suppliers sell at different prices.
  final int? precio;

  /// What the supplier charges, like [precio]; null if not set. Needed to
  /// know the profit of a sale.
  final int? costo;

  bool get tieneExistencia => piezas > 0 || piezaAbierta || cantidad > 0;

  LoteMarca copyWith({
    String? marca,
    String? proveedor,
    int? piezas,
    bool? piezaAbierta,
    int? cantidad,
    int? precio,
    int? costo,
  }) {
    return LoteMarca(
      marca: marca ?? this.marca,
      proveedor: proveedor ?? this.proveedor,
      piezas: piezas ?? this.piezas,
      piezaAbierta: piezaAbierta ?? this.piezaAbierta,
      cantidad: cantidad ?? this.cantidad,
      precio: precio ?? this.precio,
      costo: costo ?? this.costo,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LoteMarca &&
      other.marca == marca &&
      other.proveedor == proveedor &&
      other.piezas == piezas &&
      other.piezaAbierta == piezaAbierta &&
      other.cantidad == cantidad &&
      other.precio == precio &&
      other.costo == costo;

  @override
  int get hashCode => Object.hash(
    marca,
    proveedor,
    piezas,
    piezaAbierta,
    cantidad,
    precio,
    costo,
  );
}
