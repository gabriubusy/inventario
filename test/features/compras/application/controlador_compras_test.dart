import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/data/repositorio_compras_en_memoria.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/estado_pedido.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/compras/domain/resultados_compra.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  const molida = Producto(
    id: 'm',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 8000,
    lotes: [
      LoteMarca(marca: 'Propia', proveedor: 'Frigorífico 1', cantidad: 3800),
    ],
  );
  const linea = LineaCompra(
    productoId: 'm',
    producto: 'Carne molida',
    forma: FormaConteo.porKilo,
    marca: 'Propia',
    cantidad: 10000,
    costo: 450,
  );
  final hoy = DateTime(2026, 10, 27, 12);
  int? tasa = 88623;
  late ControladorExistencias existencias;
  late ControladorMovimientos movimientos;
  late ControladorCompras compras;

  Compra aCredito() => Compra(
    fecha: hoy,
    proveedor: 'Frigorífico 1',
    factura: '1240',
    lineas: const [linea],
    vence: DateTime(2026, 11, 11),
  );

  setUp(() async {
    tasa = 88623;
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria([molida]),
    );
    await existencias.cargar();
    movimientos = ControladorMovimientos(RepositorioMovimientosEnMemoria());
    compras = ControladorCompras(
      RepositorioComprasEnMemoria(),
      existencias,
      movimientos: movimientos,
      tasaDeHoy: () => tasa,
      ahora: () => hoy,
    );
    await compras.cargar();
  });

  tearDown(() {
    compras.dispose();
    movimientos.dispose();
    existencias.dispose();
  });

  LoteMarca lote() => existencias.productos.single.lotes.single;

  Future<Compra> registrada() async {
    final resultado = await compras.registrar(aCredito());
    return (resultado as CompraRegistrada).compra;
  }

  test('an order waits: it does not move the stock yet', () async {
    final compra = await registrada();
    expect(compra.tasa, 88623);
    expect(compra.estado, EstadoPedido.pendiente);
    expect(lote(), molida.lotes.single);
    expect(movimientos.todos, isEmpty);
    expect(compras.pendientes, hasLength(1));
  });

  test('what arrived raises the stock, sets the cost and notes it', () async {
    final compra = await registrada();
    final resultado = await compras.recibir(compra.id, [
      (indice: 0, piezas: 0, cantidad: 10000),
    ]);
    expect((resultado as RecepcionRegistrada).lineas, 1);
    expect(resultado.compra.estado, EstadoPedido.recibido);
    expect(lote().cantidad, 13800);
    expect(lote().costo, 450);
    final anotado = movimientos.todos.single;
    expect(anotado.tipo, TipoMovimiento.entrada);
    expect(anotado.nota, 'Factura 1240');
    expect(compras.pendientes, isEmpty);
  });

  test('less than ordered enters as it came, with the invoice kept', () async {
    final compra = await registrada();
    final resultado = await compras.recibir(compra.id, [
      (indice: 0, piezas: 0, cantidad: 9400),
    ], nota: 'El resto el jueves');
    final recibida = (resultado as RecepcionRegistrada).compra;
    expect(recibida.estado, EstadoPedido.conDiferencias);
    expect(recibida.lineas.single.diferencia, -600);
    expect(lote().cantidad, 13200);
    // The supplier still charges the whole invoice.
    expect(compras.deudaDe('Frigorífico 1'), 4500);
    expect(movimientos.todos.single.nota, 'Factura 1240 · El resto el jueves');
  });

  test('a line left empty keeps waiting for the supplier', () async {
    final resultado = await compras.registrar(
      Compra(
        fecha: hoy,
        proveedor: 'Frigorífico 1',
        lineas: const [
          linea,
          LineaCompra(
            productoId: 'm',
            producto: 'Carne molida',
            forma: FormaConteo.porKilo,
            marca: 'Nueva',
            cantidad: 2000,
            costo: 400,
          ),
        ],
        vence: DateTime(2026, 11, 11),
      ),
    );
    final compra = (resultado as CompraRegistrada).compra;
    final recibida = await compras.recibir(compra.id, [
      (indice: 0, piezas: 0, cantidad: 10000),
      (indice: 1, piezas: 0, cantidad: 0),
    ]);
    expect(
      (recibida as RecepcionRegistrada).compra.estado,
      EstadoPedido.parcial,
    );
    expect(compras.pendientes, hasLength(1));
    expect(existencias.productos.single.lotes, hasLength(1));
  });

  test('nothing written down receives nothing', () async {
    final compra = await registrada();
    expect(
      await compras.recibir(compra.id, [(indice: 0, piezas: 0, cantidad: 0)]),
      isA<RecepcionVacia>(),
    );
    expect(lote(), molida.lotes.single);
  });

  test('undoing the reception takes the goods back out', () async {
    final compra = await registrada();
    await compras.recibir(compra.id, [(indice: 0, piezas: 0, cantidad: 10000)]);
    expect(await compras.deshacerRecepcion(), isTrue);
    expect(existencias.productos.single, molida);
    expect(movimientos.todos, isEmpty);
    expect(compras.compraDe(compra.id)?.estado, EstadoPedido.pendiente);
  });

  test('an order is not undone once something arrived', () async {
    final compra = await registrada();
    await compras.recibir(compra.id, [(indice: 0, piezas: 0, cantidad: 10000)]);
    expect(await compras.deshacerCompra(), isFalse);
    expect(compras.compras, hasLength(1));
  });

  test('on credit it is owed to the supplier; cash owes nothing', () async {
    await compras.registrar(aCredito());
    expect(compras.deudaDe('frigorifico 1'), 4500);
    await compras.registrar(
      Compra(
        fecha: hoy,
        proveedor: 'Frigorífico 1',
        lineas: const [linea],
        medio: MedioPago.efectivoDolares,
      ),
    );
    expect(compras.deudaDe('Frigorífico 1'), 4500);
    expect(compras.cuentas, hasLength(1));
  });

  test('undoing a reception works with two lines of one product', () async {
    final resultado = await compras.registrar(
      Compra(
        fecha: hoy,
        proveedor: 'Frigorífico 1',
        lineas: const [
          linea,
          LineaCompra(
            productoId: 'm',
            producto: 'Carne molida',
            forma: FormaConteo.porKilo,
            marca: 'Nueva',
            cantidad: 2000,
            costo: 400,
          ),
        ],
        vence: DateTime(2026, 11, 11),
      ),
    );
    final compra = (resultado as CompraRegistrada).compra;
    await compras.recibir(compra.id, [
      (indice: 0, piezas: 0, cantidad: 10000),
      (indice: 1, piezas: 0, cantidad: 2000),
    ]);
    expect(existencias.productos.single.lotes, hasLength(2));
    expect(await compras.deshacerRecepcion(), isTrue);
    expect(existencias.productos.single, molida);
    expect(movimientos.todos, isEmpty);
  });

  test('cash in bolívares without today\'s rate is refused', () async {
    tasa = null;
    final resultado = await compras.registrar(
      Compra(
        fecha: hoy,
        proveedor: 'Frigorífico 1',
        lineas: const [linea],
        medio: MedioPago.pagoMovil,
      ),
    );
    expect(resultado, isA<CompraSinTasa>());
    expect(lote(), molida.lotes.single);
  });

  test('undo takes the order and its debt back', () async {
    await compras.registrar(aCredito());
    expect(await compras.deshacerCompra(), isTrue);
    expect(lote(), molida.lotes.single);
    expect(compras.compras, isEmpty);
    expect(movimientos.todos, isEmpty);
  });

  test('a partial payment in dollars leaves the rest owed', () async {
    await compras.registrar(aCredito());
    final cuenta = compras.cuentas.single;
    final resultado = await compras.pagar(
      cuenta,
      medio: MedioPago.zelle,
      entregado: 2000,
    );
    expect((resultado as PagoRegistrado).debe, 2500);
    expect(compras.deudaDe('Frigorífico 1'), 2500);
  });

  test('bolívares pay at today\'s rate and keep it', () async {
    await compras.registrar(aCredito());
    final resultado = await compras.pagar(
      compras.cuentas.single,
      medio: MedioPago.pagoMovil,
      entregado: 88623 * 45,
      referencia: '0412',
    );
    final pago = (resultado as PagoRegistrado).pago;
    expect(pago.monto, 4500);
    expect(pago.tasa, 88623);
    expect(resultado.debe, 0);
  });

  test(
    'more than the debt, or bolívares without a rate, are refused',
    () async {
      await compras.registrar(aCredito());
      final cuenta = compras.cuentas.single;
      expect(
        await compras.pagar(cuenta, medio: MedioPago.zelle, entregado: 4501),
        isA<PagoExcede>(),
      );
      tasa = null;
      expect(
        await compras.pagar(cuenta, medio: MedioPago.pagoMovil, entregado: 100),
        isA<PagoSinTasa>(),
      );
      expect(compras.deudaDe('Frigorífico 1'), 4500);
    },
  );

  test('undoing a payment puts the debt back', () async {
    await compras.registrar(aCredito());
    await compras.pagar(
      compras.cuentas.single,
      medio: MedioPago.zelle,
      entregado: 4500,
    );
    await compras.deshacerPago();
    expect(compras.deudaDe('Frigorífico 1'), 4500);
  });

  test('renaming the supplier keeps its invoices', () async {
    await compras.registrar(aCredito());
    await compras.renombrarProveedor('Frigorífico 1', 'Frigorífico Uno');
    expect(compras.deudaDe('Frigorífico Uno'), 4500);
  });
}
