const _sinTilde = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
};

/// Lowercases and drops accents so "jamon" finds "Jamón".
String normalizarParaBusqueda(String texto) {
  final buffer = StringBuffer();
  for (final letra in texto.trim().toLowerCase().split('')) {
    buffer.write(_sinTilde[letra] ?? letra);
  }
  return buffer.toString();
}
