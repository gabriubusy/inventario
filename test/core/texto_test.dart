import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/texto.dart';

void main() {
  test('lowercases, trims and removes accents', () {
    expect(normalizarParaBusqueda('  Jamón Ahumado '), 'jamon ahumado');
    expect(normalizarParaBusqueda('Guayanés'), 'guayanes');
    expect(normalizarParaBusqueda('Piña'), 'pina');
    expect(normalizarParaBusqueda('Pingüino'), 'pinguino');
  });

  test('keeps an empty text empty', () {
    expect(normalizarParaBusqueda('   '), '');
  });
}
