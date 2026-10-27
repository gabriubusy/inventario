import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/cuenta_por_pagar.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/compras/domain/pago.dart';
import 'package:inventario/features/compras/domain/recibir_linea.dart';
import 'package:inventario/features/compras/domain/resumen_cuentas.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  final hoy = DateTime(2026, 10, 27, 12);
  const jamon = LineaCompra(
    productoId: 'j',
    producto: 'Jamón de pierna',
    forma: FormaConteo.piezasYKilos,
    marca: 'Marca F',
    piezas: 4,
    cantidad: 16800,
    costo: 690,
  );
  const suero = LineaCompra(
    productoId: 's',
    producto: 'Suero',
    forma: FormaConteo.porLitro,
    marca: 'Marca C',
    cantidad: 48000,
    costo: 408,
  );

  Compra compra({DateTime? vence}) => Compra(
    id: 'c1',
    fecha: hoy,
    proveedor: 'Distribuidora 1',
    lineas: const [jamon, suero],
    vence: vence,
  );

  Pago pago(int monto) => Pago(
    compraId: 'c1',
    fecha: hoy,
    medio: MedioPago.zelle,
    monto: monto,
    entregado: monto,
  );

  test('a line costs its cost times its quantity, rounded to the cent', () {
    expect(jamon.subtotal, 11592);
    expect(suero.subtotal, 19584);
    expect(compra().total, 31176);
  });

  test('an account is owed what was not paid yet', () {
    final cuenta = CuentaPorPagar(
      compra: compra(vence: DateTime(2026, 11, 11)),
      pagos: [pago(10000), pago(5000)],
    );
    expect(cuenta.abonado, 15000);
    expect(cuenta.debe, 16176);
  });

  test('its state follows the due date, and paid wins over all', () {
    CuentaPorPagar cuenta(DateTime vence, [List<Pago> pagos = const []]) =>
        CuentaPorPagar(
          compra: compra(vence: vence),
          pagos: pagos,
        );
    expect(cuenta(DateTime(2026, 10, 20)).estado(hoy), EstadoCuenta.vencida);
    expect(cuenta(DateTime(2026, 11, 3)).estado(hoy), EstadoCuenta.porVencer);
    expect(cuenta(DateTime(2026, 11, 20)).estado(hoy), EstadoCuenta.alDia);
    expect(
      cuenta(DateTime(2026, 10, 20), [pago(31176)]).estado(hoy),
      EstadoCuenta.pagada,
    );
  });

  test('bolívares turn into dollars with the rate, and back', () {
    expect(aDolares(88623, Moneda.bolivares, 88623), 100);
    expect(aDolares(500, Moneda.dolares, null), 500);
    expect(aDolares(1000, Moneda.bolivares, null), isNull);
    expect(enMoneda(100, Moneda.bolivares, 88623), 88623);
  });

  test('the summary splits overdue and due this week', () {
    final resumen = ResumenCuentas.de([
      CuentaPorPagar(
        compra: compra(vence: DateTime(2026, 10, 20)),
        pagos: [],
      ),
      CuentaPorPagar(
        compra: compra(vence: DateTime(2026, 11, 1)),
        pagos: [],
      ),
      CuentaPorPagar(
        compra: compra(vence: DateTime(2026, 11, 1)),
        pagos: [pago(31176)],
      ),
    ], hoy);
    expect(resumen.debe, 62352);
    expect(resumen.vencido, 31176);
    expect(resumen.vencidas, 1);
    expect(resumen.porVencerCuantas, 1);
  });

  test('receiving a line adds to its lot and keeps the new cost', () {
    const producto = Producto(
      id: 'j',
      nombre: 'Jamón de pierna',
      categoria: Categoria.embutidos,
      forma: FormaConteo.piezasYKilos,
      minimo: 4,
      lotes: [
        LoteMarca(
          marca: 'Marca F',
          proveedor: 'Distribuidora 1',
          piezas: 3,
          cantidad: 12000,
          costo: 650,
        ),
      ],
    );
    final despues = recibirLinea(
      producto,
      jamon,
      proveedor: 'Distribuidora 1',
    ).lotes.single;
    expect(despues.piezas, 7);
    expect(despues.cantidad, 28800);
    expect(despues.costo, 690);
  });

  test('a brand new to that supplier starts its own lot', () {
    const producto = Producto(
      id: 's',
      nombre: 'Suero',
      categoria: Categoria.quesos,
      forma: FormaConteo.porLitro,
      minimo: 0,
    );
    final lote = recibirLinea(
      producto,
      suero,
      proveedor: 'Distribuidora 1',
    ).lotes.single;
    expect(lote.marca, 'Marca C');
    expect(lote.proveedor, 'Distribuidora 1');
    expect(lote.costo, 408);
  });
}
