import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/filtro_estado.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

Producto _producto(String id, String nombre, int cantidad) => Producto(
  id: id,
  nombre: nombre,
  categoria: Categoria.carnes,
  forma: FormaConteo.porKilo,
  minimo: 5000,
  lotes: [LoteMarca(marca: 'Propia', cantidad: cantidad)],
);

void main() {
  final bistec = _producto('1', 'Bistec', 10000);
  final molida = _producto('2', 'Carne molida', 2000);
  final chuleta = _producto('3', 'Chuleta', 0);
  late ControladorExistencias existencias;
  late ControladorListaProductos lista;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria([bistec, molida, chuleta]),
    );
    await existencias.cargar();
    lista = ControladorListaProductos(existencias);
  });

  tearDown(() {
    lista.dispose();
    existencias.dispose();
  });

  test('lists the most urgent first and picks the first one', () {
    expect(lista.visibles, [chuleta, molida, bistec]);
    expect(lista.elegido, chuleta);
  });

  test('the state filter narrows the list', () {
    lista.filtrar(FiltroEstado.bajo);
    expect(lista.visibles, [molida]);
    expect(lista.elegido, molida);
  });

  test('arrows move the selection and stop at the ends', () {
    lista.moverEleccion(1);
    expect(lista.elegido, molida);
    lista.moverEleccion(5);
    expect(lista.elegido, bistec);
    lista.moverEleccion(-9);
    expect(lista.elegido, chuleta);
  });

  test('keeps the choice while it is still visible', () {
    lista.elegir('1');
    lista.buscar('b');
    expect(lista.elegido, bistec);
    lista.buscar('chu');
    expect(lista.elegido, chuleta);
  });

  test('has nothing chosen when nothing matches', () {
    lista.buscar('pollo');
    expect(lista.visibles, isEmpty);
    expect(lista.elegido, isNull);
  });
}
