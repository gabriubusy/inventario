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

  test('counts calendar days whatever the time of day', () {
    expect(diasEntre(DateTime(2026, 10, 25, 23), DateTime(2026, 10, 26, 1)), 1);
    expect(diasEntre(DateTime(2026, 10, 26, 8), DateTime(2026, 10, 26, 20)), 0);
    expect(diasEntre(DateTime(2026, 9, 30), DateTime(2026, 10, 8)), 8);
  });

  test('a short date says today, yesterday or day and month', () {
    final hoy = DateTime(2026, 10, 26, 15);
    expect(formatearFechaCorta(DateTime(2026, 10, 26, 9), hoy), 'Hoy');
    expect(formatearFechaCorta(DateTime(2026, 10, 25, 22), hoy), 'Ayer');
    expect(formatearFechaCorta(DateTime(2026, 10, 18), hoy), '18 oct');
    expect(formatearFechaCorta(DateTime(2026, 9, 2), hoy), '2 sep');
  });
}
