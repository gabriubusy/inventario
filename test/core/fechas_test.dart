import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/fechas.dart';

void main() {
  test('formats the weekday, day and month in Spanish', () {
    expect(
      formatearFechaLarga(DateTime(2026, 10, 24)),
      'Sábado, 24 de octubre',
    );
    expect(formatearFechaLarga(DateTime(2026, 1, 5)), 'Lunes, 5 de enero');
    expect(formatearFechaLarga(DateTime(2026, 3, 1)), 'Domingo, 1 de marzo');
  });
}
