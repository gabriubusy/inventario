import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/entradas/domain/entrada.dart';
import 'package:inventario/features/entradas/domain/resultado_entrada.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  const molida = Producto(
    id: 'p1',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 8000,
    lotes: [
      LoteMarca(marca: 'Propia', proveedor: 'Frigorífico 1', cantidad: 3800),
    ],
  );
  const entrada = Entrada(
    marca: 'Propia',
    proveedor: 'Frigorífico 1',
    cantidad: 10000,
  );
  late ControladorExistencias existencias;
  late ControladorEntradas entradas;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria([molida]),
    );
    await existencias.cargar();
    entradas = ControladorEntradas(existencias);
  });

  tearDown(() {
    entradas.dispose();
    existencias.dispose();
  });

  int cantidadActual() => existencias.productos.single.cantidad;

  test('an entry raises the stock everyone sees', () async {
    final resultado = await entradas.registrar('p1', entrada);
    expect(resultado, isA<EntradaRegistrada>());
    expect(cantidadActual(), 13800);
    expect(entradas.puedeDeshacer, isTrue);
  });

  test('an unknown product is reported, not saved', () async {
    final resultado = await entradas.registrar('nada', entrada);
    expect(resultado, isA<ProductoNoEncontrado>());
    expect(entradas.puedeDeshacer, isFalse);
  });

  test('undo puts the product back as it was', () async {
    await entradas.registrar('p1', entrada);
    expect(await entradas.deshacer(), isTrue);
    expect(existencias.productos.single, molida);
    expect(entradas.puedeDeshacer, isFalse);
  });

  test('undo is refused when the product changed afterwards', () async {
    await entradas.registrar('p1', entrada);
    final actual = existencias.productos.single;
    await existencias.actualizarProducto(
      'p1',
      DatosProducto.desde(actual.copyWith(minimo: 1000)),
    );
    expect(await entradas.deshacer(), isFalse);
    expect(cantidadActual(), 13800);
  });

  test('there is nothing to undo at first', () async {
    expect(entradas.puedeDeshacer, isFalse);
    expect(await entradas.deshacer(), isFalse);
  });
}
