import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/unidad.dart';

void main() {
  test('derives the decimal places from the stored fractions', () {
    expect(UnidadBase.kg.decimales, 3);
    expect(UnidadBase.litro.decimales, 3);
    expect(UnidadBase.unidad.decimales, 0);
  });

  test('formats a stored quantity with its symbol', () {
    expect(UnidadBase.kg.formatear(1250), '1,25 kg');
    expect(UnidadBase.kg.formatear(18500), '18,5 kg');
    expect(UnidadBase.kg.formatear(0), '0 kg');
    expect(UnidadBase.unidad.formatear(1200), '1.200 und');
  });
}
