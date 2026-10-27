import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/domain/modo_venta.dart';
import 'package:inventario/features/salidas/domain/resultado_salida.dart';
import 'package:inventario/features/salidas/domain/salida.dart';

void main() {
  const queso = Producto(
    id: 'p1',
    nombre: 'Queso blanco duro',
    categoria: Categoria.quesos,
    forma: FormaConteo.piezasYKilos,
    minimo: 5,
    lotes: [LoteMarca(marca: 'A', piezas: 10, cantidad: 8200, precio: 520)],
  );
  const porKilo = Salida(marca: 'A', modo: ModoVenta.porPeso, cantidad: 750);
  late ControladorExistencias existencias;
  late ControladorSalidas salidas;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria([queso]),
    );
    await existencias.cargar();
    salidas = ControladorSalidas(existencias);
  });

  tearDown(() {
    salidas.dispose();
    existencias.dispose();
  });

  Producto guardado() => existencias.productos.single;

  test('a sale takes the goods out of the stock', () async {
    final resultado = await salidas.registrar('p1', porKilo);
    expect(resultado, isA<SalidaRegistrada>());
    expect(guardado().lotes.single.cantidad, 7450);
    expect(guardado().lotes.single.piezaAbierta, isTrue);
  });

  test('remembers how each product was last sold', () async {
    expect(salidas.modoPara('p1'), ModoVenta.piezaEntera);
    await salidas.registrar('p1', porKilo);
    expect(salidas.modoPara('p1'), ModoVenta.porPeso);
  });

  test('refuses a sale the stock no longer covers', () async {
    final resultado = await salidas.registrar(
      'p1',
      const Salida(marca: 'A', modo: ModoVenta.porPeso, cantidad: 9000),
    );
    expect(resultado, isA<SinExistencias>());
    expect(guardado(), queso);
  });

  test('undo puts the product back as it was', () async {
    await salidas.registrar('p1', porKilo);
    expect(await salidas.deshacer(), isTrue);
    expect(guardado(), queso);
    expect(salidas.puedeDeshacer, isFalse);
  });

  test('undo is refused when the product changed after the sale', () async {
    await salidas.registrar('p1', porKilo);
    await existencias.actualizarProducto(
      'p1',
      DatosProducto.desde(guardado().copyWith(minimo: 9)),
    );
    expect(await salidas.deshacer(), isFalse);
    expect(guardado().minimo, 9);
  });

  test('says so when the product is gone', () async {
    final resultado = await salidas.registrar('nada', porKilo);
    expect(resultado, isA<SalidaSinProducto>());
  });
}
