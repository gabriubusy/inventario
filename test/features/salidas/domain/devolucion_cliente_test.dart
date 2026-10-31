import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/salidas/domain/devolucion_cliente.dart';

void main() {
  final venta = Movimiento(
    id: 'v1',
    fecha: DateTime(2026, 10, 27, 11),
    tipo: TipoMovimiento.venta,
    productoId: 'p1',
    producto: 'Jamón de pierna',
    forma: FormaConteo.piezasYKilos,
    marca: 'Marca F',
    piezas: 1,
    cantidad: 4200,
    importe: 3780,
  );
  Movimiento devolucion(int cantidad, {String origen = 'v1'}) => Movimiento(
    fecha: DateTime(2026, 10, 27, 12),
    tipo: TipoMovimiento.devolucionCliente,
    productoId: 'p1',
    producto: 'Jamón de pierna',
    forma: FormaConteo.piezasYKilos,
    marca: 'Marca F',
    cantidad: cantidad,
    origenId: origen,
  );

  test('what is left to return discounts earlier returns of that sale', () {
    final todos = [venta, devolucion(1000), devolucion(500, origen: 'otra')];
    expect(yaDevuelto(venta, todos), 1000);
    expect(devolvible(venta, todos), 3200);
  });

  test('a cancelled sale has nothing to return', () {
    expect(devolvible(venta.anulado(), [venta]), 0);
  });

  test('the refund is the share of the amount, rounded', () {
    expect(importeDevuelto(venta, 4200), 3780);
    expect(importeDevuelto(venta, 1000), 900);
    expect(importeDevuelto(venta, 333), 300);
  });

  test('the last part of a return takes what is left of the amount', () {
    final partes = [proporcional(200, 1, 3), proporcional(200, 1, 3)];
    expect(partes, [67, 67]);
    expect(restante(200, partes), 66);
    expect(restante(null, partes), isNull);
  });
}
