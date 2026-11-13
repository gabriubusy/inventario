/// Venezuelan phone numbers: 11 digits starting with 02 or 04, however they
/// are written ("0414-000.00.00", "+58 414 0000000", "414 0000000").
bool telefonoValido(String texto) {
  var digitos = texto.replaceAll(RegExp(r'[\s().+-]'), '');
  if (digitos.startsWith('58')) digitos = digitos.substring(2);
  if (digitos.length == 10) digitos = '0$digitos';
  return RegExp(r'^0[24]\d{9}$').hasMatch(digitos);
}
