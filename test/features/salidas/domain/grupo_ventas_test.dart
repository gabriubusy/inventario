import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/salidas/domain/grupo_ventas.dart';

void main() {
  Movimiento venta(
    String producto,
    int hora, {
    String? ticket,
    int importe = 100,
    bool anulada = false,
  }) => Movimiento(
    id: '$producto$hora',
    fecha: DateTime(2026, 10, 26, hora),
    tipo: TipoMovimiento.venta,
    productoId: producto,
    producto: producto,
    forma: FormaConteo.porKilo,
    marca: 'A',
    cantidad: 1000,
    importe: importe,
    ventaId: ticket,
    anulada: anulada,
  );

  // Newest first, as the history keeps them.
  final ventas = [
    venta('Queso blanco', 18, ticket: 't2'),
    venta('Carne molida', 18, ticket: 't2', importe: 1240),
    venta('Carne molida', 11),
    venta('Jamón', 9, ticket: 't1', anulada: true),
  ];

  test('lines of a ticket go together, newest ticket first', () {
    final grupos = agruparPorTicket(ventas);
    expect(grupos.map((g) => g.ventaId), ['t2', null, 't1']);
    expect(grupos.first.lineas.map((l) => l.producto), [
      'Carne molida',
      'Queso blanco',
    ]);
  });

  test('the total leaves out cancelled lines', () {
    final grupos = agruparPorTicket(ventas);
    expect(grupos.first.total, 1340);
    expect(grupos.last.total, 0);
  });

  test('the filter keeps whole tickets that have the product', () {
    final grupos = agruparPorTicket(ventas, filtro: 'MOLIDA');
    expect(grupos.map((g) => g.ventaId), ['t2', null]);
    expect(grupos.first.lineas, hasLength(2));
  });
}
