import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/estado_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';

void main() {
  const bistec = Producto(
    id: '1',
    nombre: 'Bistec',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 5000,
    lotes: [LoteMarca(marca: 'Propia', cantidad: 10000)],
  );
  const queso = Producto(
    id: '2',
    nombre: 'Queso blanco',
    categoria: Categoria.quesos,
    forma: FormaConteo.piezasYKilos,
    minimo: 5,
    lotes: [LoteMarca(marca: 'A', piezas: 12, cantidad: 10000)],
  );
  late ControladorExistencias controlador;
  var avisos = 0;

  setUp(() {
    controlador = ControladorExistencias(
      RepositorioProductosEnMemoria([bistec, queso]),
    );
    avisos = 0;
    controlador.addListener(() => avisos++);
  });

  tearDown(() => controlador.dispose());

  test('starts loading with nothing visible', () {
    expect(controlador.estado, isA<CargandoExistencias>());
    expect(controlador.visibles, isEmpty);
  });

  test('shows every product once loaded', () async {
    await controlador.cargar();
    expect(controlador.estado, isA<ExistenciasCargadas>());
    expect(controlador.visibles, [bistec, queso]);
  });

  test('filters by search text', () async {
    await controlador.cargar();
    controlador.buscar('queso');
    expect(controlador.visibles, [queso]);
    expect(controlador.busqueda, 'queso');
  });

  test('filters by category and back to all', () async {
    await controlador.cargar();
    controlador.elegirCategoria(Categoria.carnes);
    expect(controlador.visibles, [bistec]);

    controlador.elegirCategoria(null);
    expect(controlador.visibles, [bistec, queso]);
  });

  test('does not notify when nothing changes', () async {
    await controlador.cargar();
    avisos = 0;
    controlador
      ..buscar('')
      ..elegirCategoria(null);
    expect(avisos, 0);
  });

  test('a created product shows up in the list', () async {
    await controlador.cargar();
    final resultado = await controlador.crearProducto(
      const DatosProducto(
        nombre: 'Jamón cocido',
        categoria: Categoria.embutidos,
        forma: FormaConteo.piezasYKilos,
        minimo: 2,
        lotes: [LoteMarca(marca: 'F', piezas: 3, cantidad: 12000)],
      ),
    );
    expect(resultado, isA<ProductoGuardado>());
    expect(controlador.visibles.map((p) => p.nombre), contains('Jamón cocido'));
  });

  test('an updated product keeps its place in the list', () async {
    await controlador.cargar();
    final resultado = await controlador.actualizarProducto(
      '1',
      DatosProducto.desde(bistec.copyWith(nombre: 'Bistec de res')),
    );
    expect(resultado, isA<ProductoGuardado>());
    expect(controlador.productos.map((p) => p.nombre), [
      'Bistec de res',
      'Queso blanco',
    ]);
  });

  test('a repeated name leaves the list as it was', () async {
    await controlador.cargar();
    avisos = 0;
    final resultado = await controlador.crearProducto(
      const DatosProducto(
        nombre: 'bistec',
        categoria: Categoria.carnes,
        forma: FormaConteo.porKilo,
        minimo: 0,
      ),
    );
    expect(resultado, isA<NombreRepetido>());
    expect(controlador.visibles, [bistec, queso]);
    expect(avisos, 0);
  });
}
