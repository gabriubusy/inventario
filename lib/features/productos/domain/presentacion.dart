/// A fixed pack a product is sold in: a 15 kg sack, a loose kilo, a box of
/// 12. Only for products counted by kilo, litre or unit, never by pieces.
class Presentacion {
  const Presentacion({
    required this.nombre,
    required this.factor,
    required this.precio,
    this.codigo = '',
    this.predeterminada = false,
  });

  final String nombre;

  /// How much of the base unit one holds, scaled like the stock (15000 g).
  final int factor;

  /// Dollar hundredths for one; the same for every brand.
  final int precio;

  /// Barcode or short code; empty when it has none.
  final String codigo;

  /// Offered first when selling.
  final bool predeterminada;

  Presentacion copyWith({
    String? nombre,
    int? factor,
    int? precio,
    String? codigo,
    bool? predeterminada,
  }) {
    return Presentacion(
      nombre: nombre ?? this.nombre,
      factor: factor ?? this.factor,
      precio: precio ?? this.precio,
      codigo: codigo ?? this.codigo,
      predeterminada: predeterminada ?? this.predeterminada,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Presentacion &&
      other.nombre == nombre &&
      other.factor == factor &&
      other.precio == precio &&
      other.codigo == codigo &&
      other.predeterminada == predeterminada;

  @override
  int get hashCode =>
      Object.hash(nombre, factor, precio, codigo, predeterminada);
}
