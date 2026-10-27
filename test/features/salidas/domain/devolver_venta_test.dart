import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/domain/devolver_venta.dart';

void main() {
  const queso = Producto(
    id: 'p1',
    nombre: 'Queso blanco duro',
    categoria: Categoria.quesos,
    forma: FormaConteo.piezasYKilos,
    minimo: 5,
    lotes: [
      LoteMarca(marca: 'A', proveedor: 'Lácteos', piezas: 9, cantidad: 7450),
    ],
  );

  test('a whole piece goes back to its brand lot', () {
    final devuelto = devolverVenta(
      queso,
      marca: 'A',
      proveedor: 'Lácteos',
      piezas: 1,
      cantidad: 820,
      abrioPieza: false,
    );
    expect(devuelto.lotes.single.piezas, 10);
    expect(devuelto.lotes.single.cantidad, 8270);
  });

  test('the piece a kilo sale opened is closed again', () {
    final abierto = queso.copyWith(
      lotes: [queso.lotes.single.copyWith(piezaAbierta: true)],
    );
    final devuelto = devolverVenta(
      abierto,
      marca: 'a',
      proveedor: 'lacteos',
      piezas: 0,
      cantidad: 750,
      abrioPieza: true,
    );
    expect(devuelto.lotes.single.piezas, 10);
    expect(devuelto.lotes.single.piezaAbierta, isFalse);
    expect(devuelto.lotes.single.cantidad, 8200);
  });

  test('a lot that is gone comes back as a new one', () {
    final devuelto = devolverVenta(
      queso,
      marca: 'B',
      proveedor: 'Otro',
      piezas: 1,
      cantidad: 900,
      abrioPieza: false,
    );
    expect(devuelto.lotes, hasLength(2));
    expect(devuelto.lotes.last.marca, 'B');
    expect(devuelto.lotes.last.cantidad, 900);
  });
}
