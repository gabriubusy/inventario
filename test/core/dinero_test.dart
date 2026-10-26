import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/dinero.dart';

void main() {
  test('formats dollars with two decimals', () {
    expect(formatearDolares(980), r'$ 9,80');
    expect(formatearDolares(123456), r'$ 1.234,56');
  });

  test('formats bolívares with two decimals', () {
    expect(formatearBolivares(39200), '392,00 Bs');
    expect(formatearBolivares(0), '0,00 Bs');
  });
}
