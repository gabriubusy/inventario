import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/filtro_estado.dart';
import 'package:inventario/features/productos/domain/filtro_productos.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

Producto _producto(
  String nombre,
  Categoria categoria, {
  int existencia = 10000,
}) => Producto(
  id: nombre,
  nombre: nombre,
  categoria: categoria,
  forma: FormaConteo.porKilo,
  minimo: 5000,
  lotes: [if (existencia > 0) LoteMarca(marca: 'A', cantidad: existencia)],
);

void main() {
  final bistec = _producto('Bistec', Categoria.carnes);
  final jamon = _producto('Jamón de pierna', Categoria.embutidos);
  final mortadela = _producto(
    'Mortadela',
    Categoria.embutidos,
    existencia: 1000,
  );
  final queso = _producto('Queso guayanés', Categoria.quesos, existencia: 0);
  final todos = [bistec, jamon, mortadela, queso];

  List<String> nombres(List<Producto> productos) => [
    for (final p in productos) p.nombre,
  ];

  test('finds products ignoring case and accents', () {
    expect(nombres(filtrarProductos(todos, texto: 'JAMON')), [
      'Jamón de pierna',
    ]);
    expect(nombres(filtrarProductos(todos, texto: 'guayanes')), [
      'Queso guayanés',
    ]);
  });

  test('keeps only the chosen category', () {
    expect(nombres(filtrarProductos(todos, categoria: Categoria.embutidos)), [
      'Mortadela',
      'Jamón de pierna',
    ]);
  });

  test('combines text and category', () {
    expect(
      filtrarProductos(todos, texto: 'queso', categoria: Categoria.carnes),
      isEmpty,
    );
  });

  test('puts out-of-stock first, then low, then by name', () {
    expect(nombres(filtrarProductos(todos)), [
      'Queso guayanés',
      'Mortadela',
      'Bistec',
      'Jamón de pierna',
    ]);
  });

  test('also finds products by brand', () {
    final conMarca = jamon.copyWith(
      lotes: [const LoteMarca(marca: 'Plumrose', cantidad: 5000)],
    );
    expect(filtrarProductos([bistec, conMarca], texto: 'plum'), [conMarca]);
  });

  test('the state filter keeps only low or only sold-out products', () {
    expect(nombres(filtrarProductos(todos, filtro: FiltroEstado.bajo)), [
      'Mortadela',
    ]);
    expect(nombres(filtrarProductos(todos, filtro: FiltroEstado.agotados)), [
      'Queso guayanés',
    ]);
  });
}
