import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/estado_pedido.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/compras/domain/recepcion.dart';
import 'package:inventario/features/compras/domain/resumen_pedidos.dart';
import 'package:inventario/features/compras/domain/resumen_recepcion.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

void main() {
  const molida = LineaCompra(
    productoId: 'm',
    producto: 'Carne molida',
    forma: FormaConteo.porKilo,
    marca: 'Propia',
    cantidad: 10000,
    costo: 450,
  );
  const queso = LineaCompra(
    productoId: 'q',
    producto: 'Queso blanco',
    forma: FormaConteo.piezasYKilos,
    marca: 'Marca A',
    piezas: 6,
    cantidad: 4900,
    costo: 410,
  );
  final hoy = DateTime(2026, 11, 12, 10);

  Compra pedido({List<LineaCompra> lineas = const [molida, queso]}) => Compra(
    id: 'c1',
    fecha: hoy,
    proveedor: 'Frigorífico 1',
    factura: '1240',
    lineas: lineas,
    vence: DateTime(2026, 11, 27),
  );

  test('an order with nothing confirmed is waiting', () {
    final compra = pedido();
    expect(compra.estado, EstadoPedido.pendiente);
    expect(compra.estado.esperando, isTrue);
    expect(compra.recibido, 0);
    expect(compra.porRecibir, compra.total);
  });

  test('one line confirmed and another waiting leaves it partial', () {
    final compra = pedido().conRecepcion(
      conLlegadas(pedido(), [(indice: 0, piezas: 0, cantidad: 10000)]),
      cuando: hoy,
    );
    expect(compra.estado, EstadoPedido.parcial);
    expect(compra.recibido, 4500);
    expect(compra.porRecibir, 2009);
  });

  test('everything as ordered leaves it received, with no difference', () {
    final compra = pedido().conRecepcion(
      conLlegadas(pedido(), [
        (indice: 0, piezas: 0, cantidad: 10000),
        (indice: 1, piezas: 6, cantidad: 4900),
      ]),
      cuando: hoy,
    );
    expect(compra.estado, EstadoPedido.recibido);
    expect(compra.diferencia, 0);
    expect(compra.lineasConDiferencia, 0);
  });

  test('something different leaves it received with differences', () {
    final compra = pedido().conRecepcion(
      conLlegadas(pedido(), [
        (indice: 0, piezas: 0, cantidad: 9400),
        (indice: 1, piezas: 5, cantidad: 4900),
      ]),
      cuando: hoy,
    );
    expect(compra.estado, EstadoPedido.conDiferencias);
    expect(compra.lineasConDiferencia, 2);
    expect(compra.lineas.first.diferencia, -600);
    expect(compra.lineas.last.diferenciaPiezas, -1);
    // The invoice still charges what was ordered.
    expect(compra.total, 6509);
    expect(compra.recibido, 6239);
    expect(compra.diferencia, -270);
  });

  test('a line with nothing written down keeps waiting', () {
    final lineas = conLlegadas(pedido(), [
      (indice: 0, piezas: 0, cantidad: 0),
      (indice: 1, piezas: 0, cantidad: 0),
    ]);
    expect(lineas.every((l) => !l.recibida), isTrue);
    expect(indicesDeLlegadas(pedido(), []), isEmpty);
  });

  test('a line already received is not confirmed twice', () {
    final recibida = pedido(
      lineas: [molida.conRecibido(piezas: 0, cantidad: 9400), queso],
    );
    final lineas = conLlegadas(recibida, [
      (indice: 0, piezas: 0, cantidad: 10000),
    ]);
    expect(lineas.first.cantidadRecibida, 9400);
    expect(
      indicesDeLlegadas(recibida, [(indice: 0, piezas: 0, cantidad: 10000)]),
      isEmpty,
    );
  });

  test('an entry pointing nowhere is ignored', () {
    final lineas = conLlegadas(pedido(), [
      (indice: 7, piezas: 0, cantidad: 1000),
    ]);
    expect(lineas, pedido().lineas);
  });

  test('the summary only adds up the lines being confirmed', () {
    final resumen = ResumenRecepcion.de(pedido(), [
      (indice: 0, piezas: 0, cantidad: 9400),
    ]);
    expect(resumen.lineas, 1);
    expect(resumen.valor, 4230);
    expect(resumen.diferencia, -270);
    expect(resumen.conDiferencia, 1);
    expect(resumen.vacia, isFalse);
    expect(ResumenRecepcion.de(pedido(), []).vacia, isTrue);
  });

  test('the figures count what waits and the week\'s receptions', () {
    final viejo = Compra(
      id: 'c0',
      fecha: DateTime(2026, 11, 8),
      proveedor: 'Avícola 1',
      lineas: const [molida],
      vence: DateTime(2026, 11, 23),
    );
    final recibido = pedido()
        .conRecepcion(
          conLlegadas(pedido(), [
            (indice: 0, piezas: 0, cantidad: 9400),
            (indice: 1, piezas: 6, cantidad: 4900),
          ]),
          cuando: DateTime(2026, 11, 10),
        )
        .conId('c2');
    final resumen = ResumenPedidos.de([viejo, pedido(), recibido], hoy);
    expect(resumen.pendientes, 2);
    expect(resumen.porRecibir, 4500 + 6509);
    expect(resumen.masViejo, DateTime(2026, 11, 8));
    expect(resumen.recibidos, 1);
    expect(resumen.conDiferencias, 1);
    expect(resumen.diferenciaMes, -270);
  });
}
