import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/resumen_dia.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

Movimiento _mov(
  DateTime fecha, {
  TipoMovimiento tipo = TipoMovimiento.venta,
  String id = 'p1',
  String producto = 'Queso blanco duro',
  FormaConteo forma = FormaConteo.piezasYKilos,
  int cantidad = 1000,
  int? importe,
  String? ventaId,
}) => Movimiento(
  fecha: fecha,
  tipo: tipo,
  productoId: id,
  producto: producto,
  forma: forma,
  marca: 'Marca A',
  cantidad: cantidad,
  importe: importe,
  ventaId: ventaId,
);

void main() {
  final hoy = DateTime(2026, 10, 26, 12);

  test('adds up only today\'s sales, by weight and by unit', () {
    final resumen = ResumenDia.de([
      _mov(DateTime(2026, 10, 26, 9), cantidad: 1250, importe: 650),
      _mov(
        DateTime(2026, 10, 26, 10),
        id: 'p2',
        producto: 'Salchicha',
        forma: FormaConteo.porUnidad,
        cantidad: 3,
        importe: 720,
      ),
      _mov(DateTime(2026, 10, 26, 8), tipo: TipoMovimiento.entrada),
      _mov(DateTime(2026, 10, 25, 18), cantidad: 5000, importe: 9999),
    ], hoy);
    expect(resumen.vendido, 1370);
    expect(resumen.ventas, 2);
    expect(resumen.gramos, 1250);
    expect(resumen.unidades, 3);
    expect(resumen.entradas, 1);
  });

  test('the best seller is the product that brought in most', () {
    final resumen = ResumenDia.de([
      _mov(hoy, cantidad: 1000, importe: 500),
      _mov(hoy, cantidad: 500, importe: 300),
      _mov(hoy, id: 'p2', producto: 'Jamón', cantidad: 4200, importe: 700),
    ], hoy);
    expect(resumen.masVendido, (
      producto: 'Queso blanco duro',
      importe: 800,
      cantidad: 1500,
      unidad: UnidadBase.kg,
    ));
  });

  test('a sale without price counts but adds no money', () {
    final resumen = ResumenDia.de([_mov(hoy)], hoy);
    expect(resumen.ventas, 1);
    expect(resumen.vendido, 0);
  });

  test('a cancelled sale adds nothing to the day', () {
    final resumen = ResumenDia.de([
      _mov(hoy, importe: 500),
      _mov(hoy, importe: 900).anulado(),
    ], hoy);
    expect(resumen.ventas, 1);
    expect(resumen.vendido, 500);
  });

  test('nothing sold leaves no best seller', () {
    expect(ResumenDia.de(const [], hoy).masVendido, isNull);
  });

  test('a ticket with several products is one sale', () {
    final resumen = ResumenDia.de([
      _mov(hoy, importe: 500, ventaId: 'v1'),
      _mov(hoy, id: 'p2', importe: 300, ventaId: 'v1'),
    ], hoy);
    expect(resumen.ventas, 1);
  });

  test('what came back today is no longer counted as sold', () {
    final resumen = ResumenDia.de([
      _mov(hoy, cantidad: 1000, importe: 620),
      _mov(
        hoy,
        tipo: TipoMovimiento.devolucionCliente,
        cantidad: 100,
        importe: 62,
      ),
    ], hoy);
    expect(resumen.gramos, 900);
    expect(resumen.vendido, 558);
  });
}
