import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/numeros.dart';

void main() {
  group('parseDecimal', () {
    test('accepts comma or dot as decimal separator', () {
      expect(parseDecimal('2,5'), 2500);
      expect(parseDecimal('2.5'), 2500);
      expect(parseDecimal(' 12 '), 12000);
      expect(parseDecimal(',5'), 500);
    });

    test('accepts thousands separators', () {
      expect(parseDecimal('1.234,5'), 1234500);
      expect(parseDecimal('1.234.567,89'), 1234567890);
      expect(parseDecimal('2.500'), 2500000);
      expect(parseDecimal('12.34'), 12340);
    });

    test('rejects malformed thousands groups', () {
      expect(parseDecimal('1.23,4'), isNull);
      expect(parseDecimal('1.2.3'), isNull);
      expect(parseDecimal('1,5.3'), isNull);
    });

    test('respects the requested scale', () {
      expect(parseDecimal('1,25', decimales: 2), 125);
      expect(parseDecimal('7', decimales: 0), 7);
    });

    test('rejects invalid input', () {
      expect(parseDecimal(''), isNull);
      expect(parseDecimal('abc'), isNull);
      expect(parseDecimal('-1'), isNull);
      expect(parseDecimal('1,2,3'), isNull);
      expect(parseDecimal('1,2345'), isNull);
    });
  });

  group('formatDecimal', () {
    test('groups thousands and trims trailing zeros', () {
      expect(formatDecimal(1234500), '1.234,5');
      expect(formatDecimal(2000), '2');
      expect(formatDecimal(-1500), '-1,5');
    });

    test('keeps the minimum number of decimals', () {
      expect(formatDecimal(100000, decimales: 2, minDecimales: 2), '1.000,00');
    });

    test('round-trips with parseDecimal', () {
      for (final valor in [0, 500, 2500000, 1234567, 987654321000]) {
        expect(parseDecimal(formatDecimal(valor)), valor);
      }
    });
  });

  group('dividirRedondeando', () {
    test('rounds half away from zero', () {
      expect(dividirRedondeando(5, 2), 3);
      expect(dividirRedondeando(-5, 2), -3);
      expect(dividirRedondeando(4, 3), 1);
      expect(dividirRedondeando(7, -2), -4);
    });
  });
}
