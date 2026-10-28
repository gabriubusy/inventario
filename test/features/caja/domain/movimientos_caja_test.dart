import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/caja/domain/caja.dart';
import 'package:inventario/features/caja/domain/movimiento_caja.dart';
import 'package:inventario/features/caja/domain/movimientos_caja.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/compras/domain/pago.dart';
import 'package:inventario/features/gastos/domain/categoria_gasto.dart';
import 'package:inventario/features/gastos/domain/gasto.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';
import 'package:inventario/features/salidas/domain/venta.dart';

void main() {
  final abierta = DateTime(2026, 10, 27, 8);
  DateTime a(int hora) => DateTime(2026, 10, 27, hora);
  final caja = Caja(
    id: 'k1',
    abierta: abierta,
    fondoDolares: 2000,
    fondoBolivares: 500000,
  );

  Movimiento linea(String ventaId, {bool anulada = false}) => Movimiento(
    id: 'l$ventaId',
    fecha: a(10),
    tipo: TipoMovimiento.venta,
    productoId: 'p',
    producto: 'Queso',
    forma: FormaConteo.porKilo,
    marca: 'A',
    cantidad: 1000,
    importe: 650,
    ventaId: ventaId,
    anulada: anulada,
  );

  test('opening cash, sales and change add up per way of paying', () {
    final ventas = [
      Venta(
        id: 'v1',
        fecha: a(9),
        total: 650,
        tasa: 88623,
        pagos: const [PagoVenta(medio: MedioPago.efectivoDolares, monto: 1000)],
      ),
      Venta(
        id: 'v2',
        fecha: a(10),
        total: 1000,
        tasa: 88623,
        pagos: const [
          PagoVenta(medio: MedioPago.zelle, monto: 500),
          PagoVenta(medio: MedioPago.pagoMovil, monto: 443115),
        ],
      ),
    ];
    final saldos = saldosDeCaja(
      movimientosDeCaja(caja: caja, ventas: ventas, lineas: [linea('v1')]),
    );
    expect(saldos[MedioPago.efectivoDolares], 2000 + 1000 - 350);
    expect(saldos[MedioPago.efectivoBolivares], 500000);
    expect(saldos[MedioPago.zelle], 500);
    expect(saldos[MedioPago.pagoMovil], 443115);
  });

  test('change goes back in bolívares when no dollar cash came in', () {
    final venta = Venta(
      id: 'v1',
      fecha: a(9),
      total: 50,
      tasa: 10000,
      pagos: const [
        PagoVenta(medio: MedioPago.efectivoBolivares, monto: 10000),
      ],
    );
    final saldos = saldosDeCaja(movimientosDeCaja(caja: caja, ventas: [venta]));
    expect(saldos[MedioPago.efectivoBolivares], 500000 + 10000 - 5000);
  });

  test('expenses, income, supplier payments and refunds take or add', () {
    final compra = Compra(
      id: 'c1',
      fecha: a(11),
      proveedor: 'Frigorífico 1',
      lineas: const [
        LineaCompra(
          productoId: 'p',
          producto: 'Carne',
          forma: FormaConteo.porKilo,
          marca: 'Propia',
          cantidad: 1000,
          costo: 400,
        ),
      ],
      medio: MedioPago.efectivoDolares,
    );
    final movimientos = movimientosDeCaja(
      caja: caja,
      lineas: [linea('v9', anulada: true)],
      compras: [compra],
      pagos: [
        Pago(
          compraId: 'c0',
          fecha: a(12),
          medio: MedioPago.zelle,
          monto: 1500,
          entregado: 1500,
        ),
      ],
      gastos: [
        Gasto(
          fecha: a(13),
          categoria: CategoriaGasto.servicios,
          medio: MedioPago.efectivoBolivares,
          monto: 180000,
        ),
        Gasto(
          fecha: a(14),
          categoria: CategoriaGasto.aporteDueno,
          medio: MedioPago.efectivoDolares,
          monto: 5000,
        ),
      ],
    );
    final saldos = saldosDeCaja(movimientos);
    expect(saldos[MedioPago.efectivoDolares], 2000 - 650 - 400 + 5000);
    expect(saldos[MedioPago.efectivoBolivares], 500000 - 180000);
    expect(saldos[MedioPago.zelle], -1500);
    expect(movimientos.first.tipo, TipoMovimientoCaja.ingreso);
    expect(movimientos.last.tipo, TipoMovimientoCaja.apertura);
  });

  test('a return is paid back the way it was recorded, at its rate', () {
    final devolucion = Movimiento(
      id: 'd1',
      fecha: a(11),
      tipo: TipoMovimiento.devolucionCliente,
      productoId: 'p',
      producto: 'Queso',
      forma: FormaConteo.porKilo,
      marca: 'A',
      cantidad: 500,
      importe: 325,
      tasa: 88623,
      medioReembolso: MedioPago.pagoMovil,
    );
    final movimientos = movimientosDeCaja(caja: caja, lineas: [devolucion]);
    expect(saldosDeCaja(movimientos)[MedioPago.pagoMovil], -288025);
    expect(saldosDeCaja(movimientos)[MedioPago.efectivoDolares], 2000);
  });

  test('only what happened while the till was open counts', () {
    final cerrada = caja.cerradaCon(fecha: a(12), contado: const {});
    final gastos = [
      Gasto(
        fecha: DateTime(2026, 10, 26, 18),
        categoria: CategoriaGasto.sueldos,
        medio: MedioPago.efectivoDolares,
        monto: 100,
      ),
      Gasto(
        fecha: a(13),
        categoria: CategoriaGasto.sueldos,
        medio: MedioPago.efectivoDolares,
        monto: 100,
      ),
    ];
    final movimientos = movimientosDeCaja(caja: cerrada, gastos: gastos);
    expect(movimientos.single.tipo, TipoMovimientoCaja.apertura);
  });

  test('the total in dollars converts bolívares at the rate', () {
    expect(
      totalEnDolares({
        MedioPago.efectivoDolares: 1000,
        MedioPago.pagoMovil: 88623,
      }, 88623),
      1100,
    );
  });
}
