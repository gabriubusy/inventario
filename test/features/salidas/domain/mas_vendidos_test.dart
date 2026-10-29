import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/salidas/domain/mas_vendidos.dart';

void main() {
  final hoy = DateTime(2026, 10, 29, 12);
  Movimiento venta(
    String id,
    int haceDias, {
    TipoMovimiento tipo = TipoMovimiento.venta,
    bool anulada = false,
    int hora = 9,
  }) => Movimiento(
    fecha: DateTime(2026, 10, 29 - haceDias, hora),
    tipo: tipo,
    productoId: id,
    producto: id,
    forma: FormaConteo.porKilo,
    marca: 'A',
    cantidad: 1000,
    anulada: anulada,
  );

  test('orders products by how often they were sold', () {
    expect(
      masVendidos([
        venta('queso', 0),
        venta('molida', 1),
        venta('molida', 2),
        venta('jamon', 3),
        venta('molida', 4),
        venta('jamon', 5),
      ], hoy),
      ['molida', 'jamon', 'queso'],
    );
  });

  test('leaves out old, cancelled and non-sale movements', () {
    expect(
      masVendidos([
        venta('queso', 30),
        venta('molida', 0, anulada: true),
        venta('jamon', 0, tipo: TipoMovimiento.entrada),
        venta('pollo', 29),
      ], hoy),
      ['pollo'],
    );
  });

  test('a tie goes to the one sold last, and only the first few', () {
    expect(
      masVendidos(
        [
          venta('queso', 0, hora: 8),
          venta('molida', 0, hora: 11),
          venta('jamon', 0, hora: 10),
        ],
        hoy,
        cuantos: 2,
      ),
      ['molida', 'jamon'],
    );
  });
}
