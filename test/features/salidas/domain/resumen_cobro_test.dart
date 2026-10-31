import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';
import 'package:inventario/features/salidas/domain/resumen_cobro.dart';

void main() {
  const tasa = 88730;

  test('cash in dollars over the total gives change in \$ and Bs', () {
    final cobro = ResumenCobro(
      total: 5327,
      pagos: const [PagoVenta(medio: MedioPago.efectivoDolares, monto: 6000)],
      tasa: tasa,
    );
    expect(cobro.falta, 0);
    expect(cobro.vuelto, 673);
    expect(cobro.vueltoEnBolivares, 597153);
    expect(cobro.puedeRegistrarse, isTrue);
  });

  test('a mixed payment converts the bolívares at the rate', () {
    final cobro = ResumenCobro(
      total: 5327,
      pagos: const [
        PagoVenta(medio: MedioPago.pagoMovil, monto: 3000000),
        PagoVenta(medio: MedioPago.efectivoDolares, monto: 2000),
      ],
      tasa: tasa,
    );
    expect(cobro.pagado, 5381);
    expect(cobro.vuelto, 54);
    // From the exact excess ($ 0,5404…), not from the rounded $ 0,54.
    expect(cobro.vueltoEnBolivares, 47953);
  });

  test('says what is still missing and does not let it through', () {
    final cobro = ResumenCobro(
      total: 5327,
      pagos: const [PagoVenta(medio: MedioPago.zelle, monto: 5000)],
      tasa: tasa,
    );
    expect(cobro.falta, 327);
    expect(cobro.puedeRegistrarse, isFalse);
  });

  test('paying too much without cash is not change', () {
    final cobro = ResumenCobro(
      total: 5327,
      pagos: const [PagoVenta(medio: MedioPago.zelle, monto: 6000)],
      tasa: tasa,
    );
    expect(cobro.vueltoSinEfectivo, isTrue);
    expect(cobro.puedeRegistrarse, isFalse);
  });

  test('less than one cent short in bolívares is still short', () {
    final cobro = ResumenCobro(
      total: 1000,
      tasa: 20000,
      pagos: const [PagoVenta(medio: MedioPago.pagoMovil, monto: 199901)],
    );
    expect(cobro.falta, 1);
    expect(cobro.puedeRegistrarse, isFalse);
  });

  test('change in bolívares comes from the exact amount paid', () {
    final cobro = ResumenCobro(
      total: 1000,
      tasa: 3657,
      pagos: const [
        PagoVenta(medio: MedioPago.efectivoBolivares, monto: 40000),
      ],
    );
    expect(cobro.vueltoEnBolivares, 3430);
  });

  test('the rest paid in bolívares closes the sale with no change', () {
    final antes = ResumenCobro(
      total: 100,
      tasa: 3657,
      pagos: const [PagoVenta(medio: MedioPago.pagoMovil, monto: 2000)],
    );
    final resto = antes.faltaEnBolivares;
    final cobro = ResumenCobro(
      total: 100,
      tasa: 3657,
      pagos: [
        const PagoVenta(medio: MedioPago.pagoMovil, monto: 2000),
        PagoVenta(medio: MedioPago.transferencia, monto: resto),
      ],
    );
    expect(resto, 1657);
    expect(cobro.vuelto, 0);
    expect(cobro.puedeRegistrarse, isTrue);
  });
}
