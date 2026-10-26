import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';

void main() {
  const existente = Producto(
    id: 'p1',
    nombre: 'Jamón de pierna',
    categoria: Categoria.embutidos,
    forma: FormaConteo.piezasYKilos,
    minimo: 4,
    lotes: [LoteMarca(marca: 'F', piezas: 3, cantidad: 16400)],
  );
  late RepositorioProductosEnMemoria repositorio;

  setUp(() => repositorio = RepositorioProductosEnMemoria([existente]));

  DatosProducto datos(String nombre) => DatosProducto(
    nombre: nombre,
    categoria: Categoria.quesos,
    forma: FormaConteo.piezasYKilos,
    minimo: 5,
    lotes: const [
      LoteMarca(marca: 'A', proveedor: 'D1', piezas: 10, cantidad: 8200),
      LoteMarca(marca: 'B', proveedor: 'D2', piezas: 15, cantidad: 11800),
    ],
  );

  test('creates a product with its brands', () async {
    final resultado = await repositorio.crear(datos('Queso de año'));
    final producto = (resultado as ProductoGuardado).producto;
    expect(producto.nombre, 'Queso de año');
    expect(producto.forma, FormaConteo.piezasYKilos);
    expect(producto.piezas, 25);
    expect(producto.cantidad, 20000);
    expect(await repositorio.obtenerTodos(), contains(producto));
  });

  test('gives every new product a free id', () async {
    final a = await repositorio.crear(datos('Queso de año'));
    final b = await repositorio.crear(datos('Queso paisa'));
    final ids = {
      existente.id,
      (a as ProductoGuardado).producto.id,
      (b as ProductoGuardado).producto.id,
    };
    expect(ids, hasLength(3));
  });

  test('rejects a name already used, ignoring case and accents', () async {
    final resultado = await repositorio.crear(datos('  jamon DE pierna '));
    expect(resultado, isA<NombreRepetido>());
    expect(await repositorio.obtenerTodos(), [existente]);
  });

  test('updates a product in place, keeping its id', () async {
    final resultado = await repositorio.actualizar(
      'p1',
      DatosProducto.desde(existente.copyWith(minimo: 6, imagenId: 'foto')),
    );
    final producto = (resultado as ProductoGuardado).producto;
    expect(producto.id, 'p1');
    expect(producto.minimo, 6);
    expect(producto.imagenId, 'foto');
    expect(await repositorio.obtenerTodos(), [producto]);
  });

  test('an update may keep its own name but not take another one', () async {
    await repositorio.crear(datos('Queso de año'));
    final mismo = await repositorio.actualizar(
      'p1',
      DatosProducto.desde(existente.copyWith(nombre: 'JAMON de pierna')),
    );
    expect(mismo, isA<ProductoGuardado>());
    final ajeno = await repositorio.actualizar(
      'p1',
      DatosProducto.desde(existente.copyWith(nombre: 'queso de año')),
    );
    expect(ajeno, isA<NombreRepetido>());
  });

  test('renaming a supplier updates only its lots', () async {
    await repositorio.crear(datos('Queso de año'));
    await repositorio.renombrarProveedor('d1', 'Lácteos Uno');
    final queso = (await repositorio.obtenerTodos()).last;
    expect(queso.lotes.map((l) => l.proveedor), ['Lácteos Uno', 'D2']);
  });
}
