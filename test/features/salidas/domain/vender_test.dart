import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/domain/modo_venta.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/domain/vender.dart';

void main() {
  const marcaA = LoteMarca(
    marca: 'Marca A',
    proveedor: 'Distribuidora 1',
    piezas: 10,
    cantidad: 8200,
    precio: 520,
  );
  const marcaB = LoteMarca(
    marca: 'Marca B',
    proveedor: 'Distribuidora 2',
    piezas: 14,
    piezaAbierta: true,
    cantidad: 11000,
    precio: 560,
  );
  const queso = Producto(
    id: 'p1',
    nombre: 'Queso blanco duro',
    categoria: Categoria.quesos,
    forma: FormaConteo.piezasYKilos,
    minimo: 5,
    lotes: [marcaA, marcaB],
  );
  const molida = Producto(
    id: 'p2',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 8000,
    lotes: [LoteMarca(marca: 'Propia', cantidad: 3800, precio: 620)],
  );

  Salida deA(ModoVenta modo, int cantidad) => Salida(
    marca: 'marca a',
    proveedor: 'DISTRIBUIDORA 1',
    modo: modo,
    cantidad: cantidad,
  );

  test('a whole piece takes out one piece and its real weight', () {
    final despues = vender(queso, deA(ModoVenta.piezaEntera, 840))!;
    expect(despues.lotes.first, marcaA.copyWith(piezas: 9, cantidad: 7360));
    expect(despues.lotes.last, marcaB);
  });

  test('grams left after the last whole piece can still be sold', () {
    final unaPieza = queso.copyWith(
      lotes: [marcaA.copyWith(piezas: 1, cantidad: 4000)],
    );
    final lote = vender(
      unaPieza,
      deA(ModoVenta.piezaEntera, 3950),
    )!.lotes.single;
    expect(lote.piezas, 0);
    expect(lote.cantidad, 50);
    expect(disponibleParaVender(lote, ModoVenta.porPeso), 50);
  });

  test('selling by weight with no open piece opens one', () {
    final despues = vender(queso, deA(ModoVenta.porPeso, 750))!;
    expect(despues.lotes.first.piezas, 9);
    expect(despues.lotes.first.piezaAbierta, isTrue);
    expect(despues.lotes.first.cantidad, 7450);
    expect(abrePieza(marcaA, ModoVenta.porPeso), isTrue);
  });

  test('selling by weight from an open piece keeps the whole pieces', () {
    final despues = vender(
      queso,
      const Salida(
        marca: 'Marca B',
        proveedor: 'Distribuidora 2',
        modo: ModoVenta.porPeso,
        cantidad: 500,
      ),
    )!;
    expect(despues.lotes.last.piezas, 14);
    expect(despues.lotes.last.piezaAbierta, isTrue);
    expect(abrePieza(marcaB, ModoVenta.porPeso), isFalse);
  });

  test('products sold by kilo just lose the quantity', () {
    final despues = vender(
      molida,
      const Salida(marca: 'Propia', cantidad: 1500),
    )!;
    expect(despues.cantidad, 2300);
  });

  test('refuses more than the lot holds, or a lot that is gone', () {
    expect(
      vender(molida, const Salida(marca: 'Propia', cantidad: 3801)),
      isNull,
    );
    expect(vender(molida, const Salida(marca: 'Otra', cantidad: 1)), isNull);
    expect(vender(molida, const Salida(marca: 'Propia', cantidad: 0)), isNull);
  });

  test('no whole piece can be sold from a lot with only an open piece', () {
    const soloAbierta = LoteMarca(
      marca: 'X',
      piezaAbierta: true,
      cantidad: 900,
    );
    expect(disponibleParaVender(soloAbierta, ModoVenta.piezaEntera), 0);
    expect(disponibleParaVender(soloAbierta, ModoVenta.porPeso), 900);
  });

  test('the open piece closes when its last gram is sold', () {
    final despues = vender(
      queso.copyWith(
        lotes: [
          const LoteMarca(
            marca: 'Marca A',
            proveedor: 'Distribuidora 1',
            piezaAbierta: true,
            cantidad: 300,
          ),
        ],
      ),
      deA(ModoVenta.porPeso, 300),
    )!;
    expect(despues.lotes.single.piezaAbierta, isFalse);
  });

  test('the amount is the brand price times the quantity sold', () {
    expect(importeDeSalida(queso, marcaA, 840), 437);
    expect(importeDeSalida(molida, molida.lotes.single, 750), 465);
    const sinPrecio = LoteMarca(marca: 'H', piezas: 2, cantidad: 6100);
    expect(importeDeSalida(queso, sinPrecio, 840), isNull);
  });

  test('the cost is the brand cost times the quantity sold', () {
    final conCosto = marcaA.copyWith(costo: 400);
    expect(costoDeSalida(queso, conCosto, 840), 336);
    expect(costoDeSalida(queso, marcaA, 840), isNull);
  });

  test('suggests an open piece for weight sales, else the fullest lot', () {
    expect(loteSugerido(queso, ModoVenta.porPeso), 1);
    expect(loteSugerido(queso, ModoVenta.piezaEntera), 1);
    expect(loteSugerido(queso.copyWith(lotes: [marcaA]), ModoVenta.porPeso), 0);
    expect(loteSugerido(queso.copyWith(lotes: []), ModoVenta.porPeso), isNull);
  });
}
