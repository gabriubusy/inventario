import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/configuracion/domain/ajustes_respaldo.dart';
import 'package:inventario/features/configuracion/domain/datos_negocio.dart';
import 'package:inventario/features/respaldo/domain/archivo_respaldo.dart';

void main() {
  final hoy = DateTime(2026, 10, 29, 15, 12);

  test('reminds when there was never a backup', () {
    expect(const AjustesRespaldo().hayQueRecordar(hoy), isTrue);
  });

  test('reminds once the chosen days have passed', () {
    final ajustes = AjustesRespaldo(ultimo: DateTime(2026, 10, 22, 20));
    expect(ajustes.diasSinRespaldo(hoy), 7);
    expect(ajustes.hayQueRecordar(hoy), isTrue);
    expect(ajustes.copyWith(diasRecordatorio: 8).hayQueRecordar(hoy), isFalse);
  });

  test('"Mañana" hides it for the rest of today only', () {
    final pospuesto = AjustesRespaldo(pospuestoHasta: DateTime(2026, 10, 29));
    expect(pospuesto.hayQueRecordar(hoy), isFalse);
    expect(pospuesto.hayQueRecordar(DateTime(2026, 10, 30, 8)), isTrue);
  });

  test('backup names sort by date and sizes read short', () {
    expect(nombreRespaldo(hoy), 'inventario 2026-10-29 151200.inventario');
    expect(
      nombreRespaldo(hoy, copia: 2),
      'inventario 2026-10-29 151200 (2).inventario',
    );
    expect(textoTamano(820 * 1024), '820 KB');
    expect(textoTamano(4404019), '4,2 MB');
  });

  test('the header leaves out what is empty', () {
    const datos = DatosNegocio(nombre: 'La Esquina', telefono: '0414-1234567');
    expect(datos.encabezado, 'La Esquina · 0414-1234567');
    expect(const DatosNegocio().vacio, isTrue);
  });
}
