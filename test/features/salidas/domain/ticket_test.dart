import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/domain/linea_ticket.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/domain/ticket.dart';

void main() {
  const molida = Producto(
    id: 'p1',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 0,
    lotes: [LoteMarca(marca: 'Propia', cantidad: 5000, precio: 620)],
  );
  LineaTicket kilos(int gramos, {int? importe}) => LineaTicket(
    productoId: 'p1',
    producto: 'Carne molida',
    forma: FormaConteo.porKilo,
    salida: Salida(marca: 'Propia', cantidad: gramos),
    importe: importe,
  );

  test('adds lines while the stock covers them all together', () {
    final ticket = const Ticket().agregar(molida, kilos(3000))!;
    expect(ticket.agregar(molida, kilos(2000)), isNotNull);
    expect(ticket.agregar(molida, kilos(2001)), isNull);
  });

  test('shows the product as it would be after the lines', () {
    final ticket = const Ticket().agregar(molida, kilos(3000))!;
    expect(ticket.aplicado(molida)?.cantidad, 2000);
  });

  test('the total adds up the priced lines', () {
    final ticket = Ticket([
      kilos(2000, importe: 1240),
      kilos(500),
      kilos(1000, importe: 620),
    ]);
    expect(ticket.total, 1860);
  });

  test('a line taken out goes back to its place', () {
    final ticket = Ticket([kilos(1000), kilos(2000), kilos(3000)]);
    final sin = ticket.sin(1);
    expect(sin.lineas.map((l) => l.salida.cantidad), [1000, 3000]);
    expect(sin.con(1, kilos(2000)), ticket);
  });
}
