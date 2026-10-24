import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';

void main() {
  test('accepts exactly four digits', () {
    expect(Pin.tryParse('0427')?.digitos, '0427');
  });

  test('rejects anything that is not four digits', () {
    for (final texto in ['', '123', '12345', '12a4', ' 1234', '12.4']) {
      expect(Pin.tryParse(texto), isNull, reason: texto);
    }
  });

  test('PINs with the same digits are equal', () {
    expect(Pin.tryParse('1234'), Pin.tryParse('1234'));
    expect(Pin.tryParse('1234'), isNot(Pin.tryParse('4321')));
  });

  test('does not reveal the digits when printed', () {
    expect(Pin.tryParse('1234').toString(), isNot(contains('1234')));
  });
}
