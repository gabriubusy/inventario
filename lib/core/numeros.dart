/// Parses a user-typed decimal ("2,5", "2.5", "1.234,5") into an integer scaled by 10^decimales.
/// Returns null when the text is not a valid non-negative number.
int? parseDecimal(String texto, {int decimales = 3}) {
  final limpio = texto.trim().replaceAll(' ', '');
  if (limpio.isEmpty) return null;
  final normalizado = _quitarMiles(limpio);
  if (normalizado == null) return null;
  final partes = normalizado.split(',');
  if (partes.length > 2) return null;

  final entera = partes[0].isEmpty ? '0' : partes[0];
  final fraccion = partes.length == 2 ? partes[1] : '';
  if (!RegExp(r'^\d+$').hasMatch(entera)) return null;
  if (fraccion.isNotEmpty && !RegExp(r'^\d+$').hasMatch(fraccion)) return null;
  if (fraccion.length > decimales) return null;

  final relleno = fraccion.padRight(decimales, '0');
  return int.parse(entera) * _pow10(decimales) +
      (relleno.isEmpty ? 0 : int.parse(relleno));
}

/// Formats a scaled integer with Venezuelan separators: 1.234,5
String formatDecimal(int valor, {int decimales = 3, int minDecimales = 0}) {
  final negativo = valor < 0;
  final abs = valor.abs();
  final escala = _pow10(decimales);
  final entera = abs ~/ escala;
  var fraccion = decimales == 0
      ? ''
      : (abs % escala).toString().padLeft(decimales, '0');
  while (fraccion.length > minDecimales && fraccion.endsWith('0')) {
    fraccion = fraccion.substring(0, fraccion.length - 1);
  }
  final texto = _agruparMiles(entera) + (fraccion.isEmpty ? '' : ',$fraccion');
  return negativo ? '-$texto' : texto;
}

/// Integer division rounding half away from zero.
int dividirRedondeando(int numerador, int denominador) {
  final q = numerador ~/ denominador;
  final r = numerador.remainder(denominador);
  if (r.abs() * 2 >= denominador.abs()) {
    return q + ((numerador < 0) != (denominador < 0) ? -1 : 1);
  }
  return q;
}

final _milesValidos = RegExp(r'^\d{1,3}(\.\d{3})+$');

/// Drops thousands dots so the comma is the only decimal separator.
/// "1.234" is read as thousands to round-trip with [formatDecimal].
String? _quitarMiles(String texto) {
  final coma = texto.indexOf(',');
  final entera = coma == -1 ? texto : texto.substring(0, coma);
  final resto = coma == -1 ? '' : texto.substring(coma);
  if (!entera.contains('.')) return texto;
  if (_milesValidos.hasMatch(entera)) return entera.replaceAll('.', '') + resto;
  // Without a comma, a single dot is the decimal separator ("2.5").
  if (coma == -1 && '.'.allMatches(entera).length == 1) {
    return entera.replaceAll('.', ',');
  }
  return null;
}

int _pow10(int n) {
  var r = 1;
  for (var i = 0; i < n; i++) {
    r *= 10;
  }
  return r;
}

String _agruparMiles(int n) {
  final s = n.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
