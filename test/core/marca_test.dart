import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/marca.dart';

void main() {
  test('every box of the logo fits inside its square', () {
    for (final caja in Marca.cajas) {
      expect(caja.x, greaterThanOrEqualTo(0));
      expect(caja.y, greaterThanOrEqualTo(0));
      expect(caja.x + caja.ancho, lessThanOrEqualTo(Marca.rejilla));
      expect(caja.y + caja.alto, lessThanOrEqualTo(Marca.rejilla));
    }
  });
}
