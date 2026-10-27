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
    expect(cobro.vueltoEnBolivares, 47914);
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
}
