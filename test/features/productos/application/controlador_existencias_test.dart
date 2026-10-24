import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/estado_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  const bistec = Producto(
    id: '1',
    nombre: 'Bistec',
    categoria: Categoria.carnes,
    unidad: UnidadBase.kg,
    existencia: 10000,
    minimo: 5000,
  );
  const queso = Producto(
    id: '2',
    nombre: 'Queso blanco',
    categoria: Categoria.quesos,
    unidad: UnidadBase.kg,
    existencia: 10000,
    minimo: 5000,
  );
  late ControladorExistencias controlador;
  var avisos = 0;

  setUp(() {
    controlador = ControladorExistencias(
      const RepositorioProductosEnMemoria([bistec, queso]),
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
}
