import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/data/repositorio_compras_en_memoria.dart';
import 'package:inventario/features/compras/domain/compra.dart';
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

  test('a purchase raises the stock, sets the cost and notes it', () async {
    final resultado = await compras.registrar(aCredito());
    expect(resultado, isA<CompraRegistrada>());
    expect(lote().cantidad, 13800);
    expect(lote().costo, 450);
    final anotado = movimientos.todos.single;
    expect(anotado.tipo, TipoMovimiento.entrada);
    expect(anotado.nota, 'Factura 1240');
    expect((resultado as CompraRegistrada).compra.tasa, 88623);
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

  test('undo takes the goods and the invoice back', () async {
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
