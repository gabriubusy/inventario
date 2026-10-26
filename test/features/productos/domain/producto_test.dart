import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  const queso = Producto(
    id: '1',
    nombre: 'Queso blanco duro',
    categoria: Categoria.quesos,
    forma: FormaConteo.piezasYKilos,
    minimo: 5,
    lotes: [
      LoteMarca(marca: 'A', piezas: 10, cantidad: 8200),
      LoteMarca(marca: 'B', piezas: 14, piezaAbierta: true, cantidad: 11000),
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

  test('adds up pieces, open pieces and weight across brands', () {
    expect(queso.piezas, 24);
    expect(queso.piezasAbiertas, 1);
    expect(queso.cantidad, 19200);
  });

  test('measures pieces against the minimum when counted in pieces', () {
    expect(queso.medida, 25);
    expect(queso.estado, EstadoStock.disponible);
    expect(queso.copyWith(minimo: 26).estado, EstadoStock.bajo);
  });

  test('measures the quantity for products sold by weight', () {
    expect(molida.medida, 3800);
    expect(molida.estado, EstadoStock.bajo);
    expect(molida.copyWith(minimo: 3800).estado, EstadoStock.disponible);
  });

  test('is out of stock without any brand', () {
    expect(queso.copyWith(lotes: []).estado, EstadoStock.agotado);
    expect(molida.copyWith(lotes: []).estado, EstadoStock.agotado);
  });

  test('products with the same data are equal', () {
    expect(queso, queso.copyWith(lotes: [...queso.lotes]));
    expect(queso.hashCode, queso.copyWith(lotes: [...queso.lotes]).hashCode);
    expect(queso, isNot(queso.copyWith(lotes: queso.lotes.sublist(1))));
  });

  test('the price range goes from the cheapest brand to the dearest', () {
    final conPrecios = queso.copyWith(
      lotes: [
        queso.lotes[0].copyWith(precio: 560),
        queso.lotes[1].copyWith(precio: 520),
        const LoteMarca(marca: 'C', cantidad: 0),
      ],
    );
    expect(conPrecios.rangoPrecio, (minimo: 520, maximo: 560));
  });

  test('has no price range until a brand gets a price', () {
    expect(queso.rangoPrecio, isNull);
    expect(queso.copyWith(lotes: []).rangoPrecio, isNull);
  });

  test('knows whether any brand still has stock', () {
    expect(queso.tieneExistencias, isTrue);
    expect(
      queso
          .copyWith(lotes: [const LoteMarca(marca: 'A', cantidad: 0)])
          .tieneExistencias,
      isFalse,
    );
    expect(
      queso
          .copyWith(
            lotes: [
              const LoteMarca(marca: 'A', piezaAbierta: true, cantidad: 0),
            ],
          )
          .tieneExistencias,
      isTrue,
    );
  });

  test('the photo counts for equality and survives copyWith', () {
    final conFoto = queso.copyWith(imagenId: 'abc');
    expect(conFoto, isNot(queso));
    expect(conFoto.copyWith(minimo: 6).imagenId, 'abc');
  });
}
