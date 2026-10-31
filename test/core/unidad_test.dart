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

  test('reads kilos, grams and litres the way they are typed', () {
    const kg = UnidadBase.kg;
    expect(kg.leer('1,25'), 1250);
    expect(kg.leer('1,25 kg'), 1250);
    expect(kg.leer('250 g'), 250);
    expect(kg.leer('250g'), 250);
    expect(kg.leer('250 Gr'), 250);
    expect(kg.leer('1.500 g'), 1500);
    expect(UnidadBase.litro.leer('500 ml'), 500);
    expect(UnidadBase.unidad.leer('3 und'), 3);
  });

  test('refuses what is not a quantity of that unit', () {
    expect(UnidadBase.kg.leer('250 ml'), isNull);
    expect(UnidadBase.kg.leer('12,5 g'), isNull);
    expect(UnidadBase.kg.leer('abc'), isNull);
    expect(UnidadBase.unidad.leer('2 g'), isNull);
  });
}
