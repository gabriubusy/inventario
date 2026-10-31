import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/conteo/application/controlador_conteo.dart';
import 'package:inventario/features/conteo/domain/conteo_lote.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  const salchicha = Producto(
    id: 's',
    nombre: 'Salchicha de pollo',
    categoria: Categoria.embutidos,
    forma: FormaConteo.porUnidad,
    minimo: 20,
    lotes: [
      LoteMarca(marca: 'Marca D', cantidad: 30),
      LoteMarca(marca: 'Marca E', cantidad: 18),
    ],
  );
  const molida = Producto(
    id: 'm',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 8000,
    lotes: [LoteMarca(marca: 'Propia', cantidad: 3800)],
  );
  late ControladorExistencias existencias;
  late ControladorMovimientos movimientos;
  late ControladorConteo conteo;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria([salchicha, molida]),
    );
    await existencias.cargar();
    movimientos = ControladorMovimientos(RepositorioMovimientosEnMemoria());
    conteo = ControladorConteo(existencias, movimientos: movimientos);
  });

  tearDown(() {
    conteo.dispose();
    movimientos.dispose();
    existencias.dispose();
  });

  Producto producto(String id) =>
      existencias.productos.firstWhere((p) => p.id == id);

  const conteos = [
    ConteoLote(productoId: 's', marca: 'Marca D', cantidad: 32),
    ConteoLote(productoId: 's', marca: 'Marca E', cantidad: 18),
    ConteoLote(productoId: 'm', marca: 'Propia', cantidad: 3400),
  ];

  test('saves only the lots that differ and notes each one', () async {
    expect(await conteo.guardar(conteos), 2);
    expect(producto('s').lotes.first.cantidad, 32);
    expect(producto('m').cantidad, 3400);
    final tipos = {for (final m in movimientos.todos) m.productoId: m};
    expect(tipos['s']?.tipo, TipoMovimiento.conteoSobra);
    expect(tipos['s']?.cantidad, 2);
    expect(tipos['m']?.tipo, TipoMovimiento.conteoFalta);
    expect(tipos['m']?.cantidad, 400);
  });

  test('undo puts every lot of the last count back', () async {
    await conteo.guardar(conteos);
    expect(await conteo.deshacer(), 0);
    expect(producto('s'), salchicha);
    expect(producto('m'), molida);
    expect(movimientos.todos, isEmpty);
  });

  test('undo works with two brands of the same product', () async {
    await conteo.guardar(const [
      ConteoLote(productoId: 's', marca: 'Marca D', cantidad: 32),
      ConteoLote(productoId: 's', marca: 'Marca E', cantidad: 15),
    ]);
    expect(await conteo.deshacer(), 0);
    expect(producto('s'), salchicha);
    expect(movimientos.todos, isEmpty);
  });

  test('a lot changed since keeps its count in the kardex', () async {
    await conteo.guardar(conteos);
    await existencias.actualizarProducto(
      'm',
      DatosProducto.desde(producto('m').copyWith(minimo: 9)),
    );
    expect(await conteo.deshacer(), 1);
    expect(producto('s'), salchicha);
    expect(producto('m').cantidad, 3400);
    expect(movimientos.todos.single.productoId, 'm');
  });
}
