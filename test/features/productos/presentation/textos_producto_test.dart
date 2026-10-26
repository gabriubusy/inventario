import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

void main() {
  const queso = Producto(
    id: '1',
    nombre: 'Queso blanco duro',
    categoria: Categoria.quesos,
    forma: FormaConteo.piezasYKilos,
    minimo: 5,
    lotes: [
      LoteMarca(marca: 'Marca A', piezas: 10, cantidad: 8200),
      LoteMarca(
        marca: 'Marca B',
        piezas: 14,
        piezaAbierta: true,
        cantidad: 11000,
      ),
    ],
  );
  const molida = Producto(
    id: '2',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 8000,
    lotes: [LoteMarca(marca: 'Propia', cantidad: 3800)],
  );

  test('pieces use singular and plural', () {
    expect(textoPiezas(1), '1 pieza');
    expect(textoPiezas(24), '24 piezas');
    expect(textoPiezas(1200), '1.200 piezas');
  });

  test('the main figure is pieces or the quantity', () {
    expect(textoPrincipal(queso), '24 piezas');
    expect(textoPrincipal(molida), '3,8 kg');
  });

  test('pieces show total weight and the average per piece', () {
    expect(textoPeso(queso), '19,2 kg en total · ≈ 0,77 kg por pieza');
    expect(textoPeso(molida), isNull);
  });

  test('the average needs at least one piece', () {
    expect(
      textoPromedioPorPieza(20000, 25, UnidadBase.kg),
      '≈ 0,8 kg por pieza',
    );
    expect(textoPromedioPorPieza(500, 0, UnidadBase.kg), isNull);
  });

  test('lists each brand with its stock', () {
    expect(textoMarcas(queso), 'Marca A: 10 · Marca B: 14 + 1 abierta');
    expect(textoMarcas(molida), 'Propia: 3,8 kg');
    expect(textoMarcas(molida.copyWith(lotes: [])), isNull);
  });

  test('the minimum uses the same measure as the stock', () {
    expect(textoMinimo(queso), 'mín. 5 piezas');
    expect(textoMinimo(molida), 'mín. 8 kg');
  });

  group('price', () {
    int aBolivares(int dolares) => dolares * 40;
    final unPrecio = molida.copyWith(
      lotes: [molida.lotes.single.copyWith(precio: 620)],
    );
    final dosPrecios = queso.copyWith(
      lotes: [
        queso.lotes[0].copyWith(precio: 520),
        queso.lotes[1].copyWith(precio: 560),
      ],
    );

    test('shows dollars per unit and the range across brands', () {
      expect(textoPrecio(unPrecio), r'$ 6,20 /kg');
      expect(textoPrecio(dosPrecios), r'$ 5,20–5,60 /kg');
      expect(textoPrecio(molida), isNull);
    });

    test('converts to bolívares with the rate', () {
      expect(textoPrecioBs(unPrecio, aBolivares), '248,00 Bs');
      expect(textoPrecioBs(dosPrecios, aBolivares), '208,00–224,00 Bs');
    });

    test('shows no bolívares without a rate', () {
      expect(textoPrecioBs(unPrecio, (_) => null), isNull);
    });
  });

  test('summarises how many products need attention', () {
    final agotado = molida.copyWith(id: '3', lotes: []);
    expect(
      resumenProductos([queso, molida, agotado]),
      '3 productos · 1 con stock bajo · 1 agotado',
    );
    expect(resumenProductos([queso]), '1 producto');
  });
}
