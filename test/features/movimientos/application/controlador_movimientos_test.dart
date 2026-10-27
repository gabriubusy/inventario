import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/entradas/domain/entrada.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/domain/resultado_anulacion.dart';
import 'package:inventario/features/salidas/domain/salida.dart';

void main() {
  const molida = Producto(
    id: 'p1',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 8000,
    lotes: [
      LoteMarca(
        marca: 'Propia',
        proveedor: 'Frigorífico 1',
        cantidad: 10000,
        precio: 620,
      ),
    ],
  );
  var ahora = DateTime(2026, 10, 26, 11, 42);
  late ControladorExistencias existencias;
  late ControladorMovimientos movimientos;
  late ControladorSalidas salidas;
  late ControladorEntradas entradas;

  setUp(() async {
    ahora = DateTime(2026, 10, 26, 11, 42);
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria([molida]),
    );
    await existencias.cargar();
    movimientos = ControladorMovimientos(
      RepositorioMovimientosEnMemoria(),
      ahora: () => ahora,
    );
    await movimientos.cargar();
    salidas = ControladorSalidas(existencias, movimientos: movimientos);
    entradas = ControladorEntradas(existencias, movimientos: movimientos);
  });

  tearDown(() {
    salidas.dispose();
    entradas.dispose();
    movimientos.dispose();
    existencias.dispose();
  });

  const venta = Salida(
    marca: 'Propia',
    proveedor: 'Frigorífico 1',
    cantidad: 2000,
  );

  test('a sale is noted with its amount and time', () async {
    await salidas.registrar('p1', venta);
    final anotada = movimientos.ultimasVentas().single;
    expect(anotada.tipo, TipoMovimiento.venta);
    expect(anotada.producto, 'Carne molida');
    expect(anotada.cantidad, 2000);
    expect(anotada.importe, 1240);
    expect(anotada.fecha, ahora);
    expect(anotada.id, isNotEmpty);
  });

  test('undoing the sale removes it from the history', () async {
    await salidas.registrar('p1', venta);
    await salidas.deshacer();
    expect(movimientos.todos, isEmpty);
  });

  test('an entry is noted but is not a sale', () async {
    await entradas.registrar(
      'p1',
      const Entrada(marca: 'Propia', proveedor: 'Frigorífico 1', cantidad: 500),
    );
    expect(movimientos.todos.single.tipo, TipoMovimiento.entrada);
    expect(movimientos.ultimasVentas(), isEmpty);
    expect(movimientos.resumenDeHoy.entradas, 1);
    await entradas.deshacer();
    expect(movimientos.todos, isEmpty);
  });

  test(
    'cancelling a sale gives the stock back and keeps it crossed out',
    () async {
      await salidas.registrar('p1', venta);
      final anotada = movimientos.ventasDeHoy.single;
      expect(await salidas.anular(anotada), isA<VentaAnulada>());
      expect(existencias.productos.single, molida);
      expect(movimientos.ventasDeHoy.single.anulada, isTrue);
      expect(movimientos.resumenDeHoy.ventas, 0);
      expect(salidas.puedeDeshacer, isFalse);
    },
  );

  test('a sale cannot be cancelled twice', () async {
    await salidas.registrar('p1', venta);
    await salidas.anular(movimientos.ventasDeHoy.single);
    final anulada = movimientos.ventasDeHoy.single;
    expect(await salidas.anular(anulada), isA<YaAnulada>());
    expect(existencias.productos.single, molida);
  });

  test('latest sales are today\'s, newest first, up to the limit', () async {
    ahora = DateTime(2026, 10, 25, 18);
    await salidas.registrar('p1', venta);
    ahora = DateTime(2026, 10, 26, 9);
    await salidas.registrar('p1', venta);
    ahora = DateTime(2026, 10, 26, 10);
    await salidas.registrar('p1', venta);
    final ultimas = movimientos.ultimasVentas(limite: 5);
    expect(ultimas.map((m) => m.fecha), [
      DateTime(2026, 10, 26, 10),
      DateTime(2026, 10, 26, 9),
    ]);
    expect(movimientos.ultimasVentas(limite: 1), hasLength(1));
  });
}
