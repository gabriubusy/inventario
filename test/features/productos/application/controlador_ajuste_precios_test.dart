import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/application/controlador_ajuste_precios.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/ambito_ajuste.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/regla_precio.dart';

void main() {
  late ControladorExistencias existencias;
  late ControladorAjustePrecios ajuste;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const [
        Producto(
          id: 'p1',
          nombre: 'Carne molida',
          categoria: Categoria.carnes,
          forma: FormaConteo.porKilo,
          minimo: 0,
          lotes: [
            LoteMarca(
              marca: 'Propia',
              proveedor: 'Frigorífico',
              cantidad: 1000,
              precio: 600,
            ),
          ],
          reglas: {ListaPrecio.mayor: PrecioFijo(500)},
        ),
        Producto(
          id: 'p2',
          nombre: 'Queso',
          categoria: Categoria.quesos,
          forma: FormaConteo.porKilo,
          minimo: 0,
          lotes: [
            LoteMarca(
              marca: 'Llanero',
              proveedor: 'Lácteos',
              cantidad: 1000,
              precio: 800,
            ),
          ],
        ),
      ]),
    );
    await existencias.cargar();
    ajuste = ControladorAjustePrecios(existencias);
  });

  tearDown(() => existencias.dispose());

  Producto guardado(String id) =>
      existencias.productos.firstWhere((p) => p.id == id);

  test('raises Detal by 10 % on every product', () async {
    expect(
      await ajuste.aplicar(const TodosLosProductos(), ListaPrecio.detal, 1000),
      2,
    );
    expect(guardado('p1').lotes.single.precio, 660);
    expect(guardado('p2').lotes.single.precio, 880);
  });

  test('only touches the chosen category or supplier', () async {
    await ajuste.aplicar(
      const DeCategoria(Categoria.quesos),
      ListaPrecio.detal,
      1000,
    );
    expect(guardado('p1').lotes.single.precio, 600);
    await ajuste.aplicar(
      const DeProveedor('frigorifico'),
      ListaPrecio.detal,
      -1000,
    );
    expect(guardado('p1').lotes.single.precio, 540);
    expect(guardado('p2').lotes.single.precio, 880);
  });

  test('a list without a rule leaves the product out', () {
    final previsto = ajuste.previsto(
      const TodosLosProductos(),
      ListaPrecio.mayor,
      1000,
    );
    expect(previsto.map((c) => c.antes.id), ['p1']);
    expect(
      previsto.single.despues.reglas[ListaPrecio.mayor],
      const PrecioFijo(550),
    );
  });

  test('undo puts every price back', () async {
    await ajuste.aplicar(const TodosLosProductos(), ListaPrecio.detal, 1000);
    expect(await ajuste.deshacer(), isTrue);
    expect(guardado('p1').lotes.single.precio, 600);
    expect(guardado('p2').lotes.single.precio, 800);
  });

  test('undo is refused when a product changed since', () async {
    await ajuste.aplicar(const TodosLosProductos(), ListaPrecio.detal, 1000);
    await existencias.actualizarProducto(
      'p2',
      DatosProducto.desde(guardado('p2').copyWith(minimo: 5)),
    );
    expect(await ajuste.deshacer(), isFalse);
    expect(guardado('p1').lotes.single.precio, 660);
  });
}
