import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';

void main() {
  final tasa = TasaCambio(
    bolivaresPorDolar: 3960,
    fecha: DateTime(2026, 10, 24, 9, 30),
  );

  test('converts dollars to bolívares, rounding to the cent', () {
    expect(tasa.aBolivares(980), 38808);
    expect(tasa.aBolivares(1), 40);
  });

  test('belongs to its day whatever the time', () {
    expect(tasa.esDelDia(DateTime(2026, 10, 24, 23, 59)), isTrue);
    expect(tasa.esDelDia(DateTime(2026, 10, 25)), isFalse);
  });

  test('measures the change from the previous rate in hundredths of %', () {
    TasaCambio con(int valor, int? anterior) => TasaCambio(
      bolivaresPorDolar: valor,
      fecha: DateTime(2026, 10, 26),
      anterior: anterior,
    );
    expect(con(88623, 88475).variacion, 17);
    expect(con(88475, 88623).variacion, -17);
    expect(con(88623, 88623).variacion, 0);
    expect(con(88623, null).variacion, isNull);
  });

  test('two rates of the same day and value are equal', () {
    final otra = TasaCambio(
      bolivaresPorDolar: 3960,
      fecha: DateTime(2026, 10, 24, 18),
    );
    expect(otra, tasa);
    expect(otra.hashCode, tasa.hashCode);
  });
}
