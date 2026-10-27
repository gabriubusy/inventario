import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/kardex/domain/filtro_kardex.dart';
import 'package:inventario/features/kardex/domain/linea_kardex.dart';
import 'package:inventario/features/kardex/domain/resumen_kardex.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

Movimiento _mov(TipoMovimiento tipo, DateTime fecha, int cantidad) =>
    Movimiento(
      fecha: fecha,
      tipo: tipo,
      productoId: 'p1',
      producto: 'Carne molida',
      forma: FormaConteo.porKilo,
      marca: 'Propia',
      cantidad: cantidad,
    );

void main() {
  final hoy = DateTime(2026, 10, 27, 12);
  final entrada = _mov(
    TipoMovimiento.entrada,
    DateTime(2026, 10, 26, 8),
    10000,
  );
  final venta = _mov(TipoMovimiento.venta, DateTime(2026, 10, 27, 9), 2000);
  final merma = _mov(TipoMovimiento.merma, DateTime(2026, 10, 27, 10), 400);
  final devolucion = _mov(
    TipoMovimiento.devolucionCliente,
    DateTime(2026, 10, 27, 11),
    500,
  );

  test('the balance runs backwards from today\'s stock, newest first', () {
    final lineas = lineasKardex([entrada, venta, merma, devolucion], 8100);
    expect([for (final l in lineas) l.saldo], [8100, 7600, 8000, 10000]);
    expect(lineas.first.entra, 500);
    expect(lineas[1].sale, 400);
  });

  test('a cancelled sale leaves the kardex', () {
    final lineas = lineasKardex([entrada, venta.anulado()], 10000);
    expect(lineas, hasLength(1));
    expect(lineas.single.saldo, 10000);
  });

  test('filters keep the balances computed over everything', () {
    final lineas = lineasKardex([entrada, venta, merma], 7600);
    final perdidas = filtrarKardex(
      lineas,
      grupo: GrupoMovimiento.perdidas,
      periodo: PeriodoKardex.todo,
      hoy: hoy,
    );
    expect(perdidas.single.saldo, 7600);
    final deHoy = filtrarKardex(lineas, periodo: PeriodoKardex.hoy, hoy: hoy);
    expect(deHoy, hasLength(2));
  });

  test('summary splits what came in, was sold and was lost', () {
    final resumen = ResumenKardex.de(
      lineasKardex([entrada, venta, merma, devolucion], 8100),
    );
    expect(
      resumen,
      const ResumenKardex(
        entro: 10500,
        entradas: 2,
        vendido: 2000,
        ventas: 1,
        perdido: 400,
      ),
    );
  });

  test('brands match ignoring case and accents', () {
    expect(esDeMarca('Marca Á', 'marca a'), isTrue);
    expect(esDeMarca('Marca A', 'Marca B'), isFalse);
  });
}
