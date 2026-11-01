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

  /// Words a person may type after the number for this unit.
  Set<String> get _nombres => switch (this) {
    UnidadBase.kg => const {'kg', 'k', 'kgs', 'kilo', 'kilos'},
    UnidadBase.litro => const {'l', 'lt', 'lts', 'litro', 'litros'},
    UnidadBase.unidad => const {'und', 'u', 'unidad', 'unidades'},
  };

  /// The small unit (a thousandth): grams and millilitres.
  Set<String> get _nombresMinimos => switch (this) {
    UnidadBase.kg => const {'g', 'gr', 'grs', 'gramo', 'gramos'},
    UnidadBase.litro => const {'ml', 'cc'},
    UnidadBase.unidad => const {},
  };

  /// Whether grams or millilitres can be typed.
  bool get tieneMinimo => _nombresMinimos.isNotEmpty;

  /// Reads what was typed as a stored quantity: "1,25", "1.25", "1,25 kg",
  /// "250 g" or "250g" for kilos; "500 ml" for litres. With [enMinimo] a bare
  /// number is grams or millilitres. Null when it is not one.
  int? leer(String texto, {bool enMinimo = false}) {
    final partes = RegExp(r'^([0-9.,]*)\s*([a-z]*)$')
        .firstMatch(texto.trim().toLowerCase());
    if (partes == null) return null;
    final numero = partes.group(1)!;
    final unidad = partes.group(2)!;
    final minimo =
        _nombresMinimos.contains(unidad) ||
        (unidad.isEmpty && enMinimo && tieneMinimo);
    if (minimo) {
      final minimos = parseDecimal(numero, decimales: 0);
      return minimos == null ? null : minimos * fraccionesPorUnidad ~/ 1000;
    }
    if (unidad.isNotEmpty && !_nombres.contains(unidad)) return null;
    return parseDecimal(_puntoDecimal(numero), decimales: decimales);
  }

  /// Scales show "1.500" for 1,5 kg: a lone dot is the decimal separator here.
  String _puntoDecimal(String numero) =>
      decimales > 0 &&
          !numero.contains(',') &&
          '.'.allMatches(numero).length == 1
      ? numero.replaceFirst('.', ',')
      : numero;
}
