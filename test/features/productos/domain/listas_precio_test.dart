import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/domain/ajustar_precios.dart';
import 'package:inventario/features/productos/domain/ambito_ajuste.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/precio_en_lista.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/regla_precio.dart';

void main() {
  const propia = LoteMarca(
    marca: 'Propia',
    cantidad: 10000,
    precio: 620,
    costo: 410,
  );
  const montana = LoteMarca(
    marca: 'Montana',
    cantidad: 5000,
    precio: 650,
    costo: 440,
  );
  const sinCosto = LoteMarca(marca: 'X', cantidad: 1000, precio: 700);
  const molida = Producto(
    id: 'p1',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 0,
    lotes: [propia, montana, sinCosto],
    reglas: {
      ListaPrecio.mayor: MargenSobreCosto(3000),
      ListaPrecio.especial: PrecioFijo(500),
    },
  );

  test('Detal is each brand\'s own price', () {
    expect(precioDeLote(molida, propia, ListaPrecio.detal), 620);
    expect(precioDeLote(molida, montana, ListaPrecio.detal), 650);
  });

  test('cost plus margin gives a price per brand', () {
    expect(precioDeLote(molida, propia, ListaPrecio.mayor), 533);
    expect(precioDeLote(molida, montana, ListaPrecio.mayor), 572);
  });

  test('without a cost or a rule a list falls back to Detal', () {
    expect(precioDeLote(molida, sinCosto, ListaPrecio.mayor), 700);
    final sinReglas = molida.copyWith(reglas: const {});
    expect(precioDeLote(sinReglas, propia, ListaPrecio.especial), 620);
  });

  test('a fixed price is the same for every brand', () {
    expect(precioDeLote(molida, propia, ListaPrecio.especial), 500);
    expect(precioDeLote(molida, montana, ListaPrecio.especial), 500);
  });

  test('a rule applies to a pack by its size', () {
    const saco = Presentacion(nombre: 'Saco', factor: 15000, precio: 3200);
    expect(precioDePresentacion(molida, saco, propia, ListaPrecio.detal), 3200);
    expect(
      precioDePresentacion(molida, saco, propia, ListaPrecio.especial),
      7500,
    );
    expect(precioDePresentacion(molida, saco, propia, ListaPrecio.mayor), 7995);
  });

  test('a mass change moves Detal prices and packs', () {
    final subido = ajustarPrecios(molida, ListaPrecio.detal, 1000);
    expect(subido.lotes.map((l) => l.precio), [682, 715, 770]);
    expect(subido.reglas, molida.reglas);
  });

  test('a mass change moves a rule so its result moves the same', () {
    final mayor = ajustarPrecios(molida, ListaPrecio.mayor, 1000);
    expect(mayor.reglas[ListaPrecio.mayor], const MargenSobreCosto(4300));
    expect(precioDeLote(mayor, propia, ListaPrecio.mayor), 586);
    final especial = ajustarPrecios(molida, ListaPrecio.especial, -1000);
    expect(especial.reglas[ListaPrecio.especial], const PrecioFijo(450));
  });

  test('a list without a rule is not touched by a mass change', () {
    final sinReglas = molida.copyWith(reglas: const {});
    expect(ajustarPrecios(sinReglas, ListaPrecio.mayor, 1000), sinReglas);
  });

  test('lowering by 100 % or more changes nothing', () {
    const harina = Producto(
      id: 'h',
      nombre: 'Harina',
      categoria: Categoria.carnes,
      forma: FormaConteo.porKilo,
      minimo: 0,
      lotes: [LoteMarca(marca: 'P', cantidad: 1000, precio: 200)],
    );
    expect(ajustarPrecios(harina, ListaPrecio.detal, -10000), harina);
    expect(ajustarPrecios(harina, ListaPrecio.detal, -15000), harina);
  });

  test('by supplier only that supplier brands move', () {
    const queso = Producto(
      id: 'q',
      nombre: 'Queso',
      categoria: Categoria.quesos,
      forma: FormaConteo.porKilo,
      minimo: 0,
      lotes: [
        LoteMarca(marca: 'A', proveedor: 'X', cantidad: 1000, precio: 500),
        LoteMarca(marca: 'B', proveedor: 'Y', cantidad: 1000, precio: 600),
      ],
      presentaciones: [Presentacion(nombre: 'Kilo', factor: 1000, precio: 550)],
    );
    const ambito = DeProveedor('x');
    final subido = ajustarPrecios(
      queso,
      ListaPrecio.detal,
      1000,
      lote: ambito.incluyeLote,
      presentaciones: ambito.incluyePresentaciones,
    );
    expect(subido.lotes.map((l) => l.precio), [550, 600]);
    expect(subido.presentaciones.single.precio, 550);
  });
}
