import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/data/repositorio_ventas_en_memoria.dart';
import 'package:inventario/features/salidas/domain/linea_ticket.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';
import 'package:inventario/features/salidas/domain/resultado_cobro.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/domain/ticket.dart';

void main() {
  const molida = Producto(
    id: 'p1',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 0,
    lotes: [LoteMarca(marca: 'Propia', cantidad: 10000, precio: 620)],
  );
  const jamon = Producto(
    id: 'p2',
    nombre: 'Jamón de pierna',
    categoria: Categoria.embutidos,
    forma: FormaConteo.porKilo,
    minimo: 0,
    lotes: [LoteMarca(marca: 'Marca F', cantidad: 4000, precio: 900)],
  );
  LineaTicket linea(Producto producto, int gramos, int importe) => LineaTicket(
    productoId: producto.id,
    producto: producto.nombre,
    forma: producto.forma,
    salida: Salida(marca: producto.lotes.single.marca, cantidad: gramos),
    importe: importe,
  );
  final ticket = Ticket([
    linea(molida, 2000, 1240),
    linea(jamon, 500, 450),
    linea(molida, 1000, 620),
  ]);
  const efectivo = [PagoVenta(medio: MedioPago.efectivoDolares, monto: 2500)];
  late ControladorExistencias existencias;
  late ControladorMovimientos movimientos;
  late RepositorioVentasEnMemoria ventas;
  late ControladorSalidas salidas;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria([molida, jamon]),
    );
    await existencias.cargar();
    movimientos = ControladorMovimientos(RepositorioMovimientosEnMemoria());
    ventas = RepositorioVentasEnMemoria();
    salidas = ControladorSalidas(
      existencias,
      movimientos: movimientos,
      ventas: ventas,
      tasaDeHoy: () => 88730,
    );
  });

  tearDown(() {
    salidas.dispose();
    movimientos.dispose();
    existencias.dispose();
  });

  int cantidadDe(String id) =>
      existencias.productos.firstWhere((p) => p.id == id).cantidad;

  test(
    'a paid ticket takes every line out and keeps how it was paid',
    () async {
      final resultado = await salidas.cobrar(ticket, efectivo);
      expect(resultado, isA<VentaCobrada>());
      expect(cantidadDe('p1'), 7000);
      expect(cantidadDe('p2'), 3500);
      final venta = (await ventas.obtenerTodas()).single;
      expect(venta.total, 2310);
      expect(venta.tasa, 88730);
      expect(venta.pagos, efectivo);
      expect(movimientos.ventasDeHoy, hasLength(3));
      expect(
        movimientos.ventasDeHoy.every((m) => m.ventaId == venta.id),
        isTrue,
      );
    },
  );

  test('the history keeps what was charged even if the price moved', () async {
    // The ticket's line was priced at $5,00/kg; the brand now says $6,20.
    await salidas.cobrar(Ticket([linea(molida, 1000, 500)]), const [
      PagoVenta(medio: MedioPago.efectivoDolares, monto: 500),
    ]);
    expect(movimientos.ventasDeHoy.single.importe, 500);
  });

  test('undo puts every product back and forgets the sale', () async {
    await salidas.cobrar(ticket, efectivo);
    expect(await salidas.deshacer(), isTrue);
    expect(existencias.productos, [molida, jamon]);
    expect(movimientos.todos, isEmpty);
    expect(await ventas.obtenerTodas(), isEmpty);
  });

  test('refuses a payment short of the total', () async {
    final resultado = await salidas.cobrar(ticket, const [
      PagoVenta(medio: MedioPago.efectivoDolares, monto: 2000),
    ]);
    expect(resultado, isA<CobroIncompleto>());
    expect(existencias.productos, [molida, jamon]);
  });

  test('names the line the stock no longer covers and sells nothing', () async {
    await existencias.actualizarProducto(
      'p2',
      DatosProducto.desde(
        jamon.copyWith(lotes: [jamon.lotes.single.copyWith(cantidad: 300)]),
      ),
    );
    final resultado = await salidas.cobrar(ticket, efectivo);
    expect(resultado, isA<CobroSinExistencias>());
    expect(
      (resultado as CobroSinExistencias).linea.producto,
      'Jamón de pierna',
    );
    expect(cantidadDe('p1'), 10000);
  });
}
