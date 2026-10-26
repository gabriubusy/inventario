import 'package:inventario/core/unidad.dart';

/// How a product's stock is counted and sold.
enum FormaConteo {
  piezasYKilos('Piezas y kilos', 'Quesos, jamones', UnidadBase.kg, true),
  porKilo('Por kilo', 'Carne molida', UnidadBase.kg, false),
  porLitro('Por litro', 'Suero', UnidadBase.litro, false),
  porUnidad('Por unidad', 'Paquetes', UnidadBase.unidad, false);

  const FormaConteo(
    this.etiqueta,
    this.ejemplo,
    this.unidad,
    this.cuentaPiezas,
  );

  final String etiqueta;
  final String ejemplo;

  /// Unit of the measured quantity; for pieces it is their weight.
  final UnidadBase unidad;

  /// Pieces are counted on top of the weight (25 cheeses = 20 kg).
  final bool cuentaPiezas;
}
