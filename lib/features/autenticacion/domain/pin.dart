/// A login PIN; build it with [tryParse] so it is always [longitud] digits.
class Pin {
  const Pin._(this.digitos);

  static const longitud = 4;
  static final _formato = RegExp('^\\d{$longitud}\$');

  static Pin? tryParse(String texto) =>
      _formato.hasMatch(texto) ? Pin._(texto) : null;

  final String digitos;

  @override
  bool operator ==(Object other) => other is Pin && other.digitos == digitos;

  @override
  int get hashCode => digitos.hashCode;

  // Never print the digits in logs.
  @override
  String toString() => 'Pin(****)';
}
