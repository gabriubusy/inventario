import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/telefono.dart';

void main() {
  test('accepts a mobile number with dashes and dots', () {
    expect(telefonoValido('0414-123.45.67'), isTrue);
  });

  test('accepts a landline with spaces', () {
    expect(telefonoValido('0212 123 4567'), isTrue);
  });

  test('accepts the country code', () {
    expect(telefonoValido('+58 414 1234567'), isTrue);
  });

  test('accepts the number without its leading zero', () {
    expect(telefonoValido('414 1234567'), isTrue);
  });

  test('rejects an area code that is not Venezuelan', () {
    expect(telefonoValido('0314-123.45.67'), isFalse);
  });

  test('rejects too few digits', () {
    expect(telefonoValido('0414-123'), isFalse);
  });

  test('rejects too many digits', () {
    expect(telefonoValido('0414-123.45.678'), isFalse);
  });

  test('rejects letters', () {
    expect(telefonoValido('llamar al 0414'), isFalse);
  });
}
