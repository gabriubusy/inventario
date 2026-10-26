import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/data/repositorio_proveedores_en_memoria.dart';
import 'package:inventario/features/proveedores/domain/datos_proveedor.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/domain/resultado_guardar_proveedor.dart';

void main() {
  const frigorifico = Proveedor(id: 'v1', nombre: 'Frigorífico 1');
  const distribuidora = Proveedor(id: 'v2', nombre: 'Distribuidora 1');
  const avicola = Proveedor(id: 'v3', nombre: 'Avícola 1');
  late ControladorExistencias existencias;
  late ControladorProveedores controlador;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const [
        Producto(
          id: 'p1',
          nombre: 'Queso blanco duro',
          categoria: Categoria.quesos,
          forma: FormaConteo.piezasYKilos,
          minimo: 5,
          lotes: [
            LoteMarca(
              marca: 'Marca A',
              proveedor: 'Distribuidora 1',
              piezas: 10,
              cantidad: 8200,
            ),
          ],
        ),
      ]),
    );
    await existencias.cargar();
    controlador = ControladorProveedores(
      RepositorioProveedoresEnMemoria([frigorifico, distribuidora, avicola]),
      existencias,
    );
    await controlador.cargar();
  });

  tearDown(() {
    controlador.dispose();
    existencias.dispose();
  });

  test('lists suppliers by name and picks the first one', () {
    expect(controlador.visibles, [avicola, distribuidora, frigorifico]);
    expect(controlador.elegido, avicola);
  });

  test('finds a supplier by a brand it brings', () {
    controlador.buscar('marca a');
    expect(controlador.visibles, [distribuidora]);
    expect(controlador.elegido, distribuidora);
  });

  test('names ignore the search, for suggestions elsewhere', () {
    controlador.buscar('marca a');
    expect(controlador.nombres, hasLength(3));
  });

  test('arrows move the selection and stop at the ends', () {
    controlador.moverEleccion(1);
    expect(controlador.elegido, distribuidora);
    controlador.moverEleccion(5);
    expect(controlador.elegido, frigorifico);
    controlador.moverEleccion(-9);
    expect(controlador.elegido, avicola);
  });

  test('shows what a supplier brings from the stock', () {
    final suministros = controlador.suministros(distribuidora);
    expect(suministros.single.producto.nombre, 'Queso blanco duro');
    expect(controlador.suministros(avicola), isEmpty);
  });

  test('a new supplier is listed and selected', () async {
    final resultado = await controlador.crear(
      const DatosProveedor(nombre: 'Lácteos 1'),
    );
    final nuevo = (resultado as ProveedorGuardado).proveedor;
    expect(controlador.visibles, contains(nuevo));
    expect(controlador.elegido, nuevo);
  });

  test('renaming a supplier keeps its products linked', () async {
    await controlador.actualizar(
      distribuidora,
      const DatosProveedor(nombre: 'Distribuidora Uno'),
    );
    final renombrado = controlador.visibles.firstWhere((p) => p.id == 'v2');
    expect(renombrado.nombre, 'Distribuidora Uno');
    expect(controlador.suministros(renombrado), hasLength(1));
  });

  test('a repeated name changes nothing', () async {
    final resultado = await controlador.actualizar(
      distribuidora,
      const DatosProveedor(nombre: 'avicola 1'),
    );
    expect(resultado, isA<NombreProveedorRepetido>());
    expect(controlador.visibles, [avicola, distribuidora, frigorifico]);
  });
}
