import 'package:inventario/core/numeros.dart';

enum UnidadBase {
  kg('kg', 'g', 1000),
  litro('l', 'ml', 1000),
  unidad('und', 'und', 1);

  const UnidadBase(this.simbolo, this.simboloMinimo, this.fraccionesPorUnidad);

  final String simbolo;
  final String simboloMinimo;

  /// How many stored integers make one base unit (1 kg = 1000 g).
  final int fraccionesPorUnidad;

  /// Decimal places of a stored quantity; [fraccionesPorUnidad] is a power of ten.
  int get decimales => fraccionesPorUnidad.toString().length - 1;

  String get etiqueta => switch (this) {
    UnidadBase.kg => 'Kilogramo (kg)',
    UnidadBase.litro => 'Litro (l)',
    UnidadBase.unidad => 'Unidad (und)',
  };

  /// Formats a stored quantity with its symbol: 1250 → "1,25 kg".
  String formatear(int cantidad) =>
      '${formatDecimal(cantidad, decimales: decimales)} $simbolo';
}
