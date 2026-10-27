import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/caja/application/controlador_caja.dart';
import 'package:inventario/features/caja/data/repositorio_cajas_en_memoria.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/gastos/data/repositorio_gastos_en_memoria.dart';
import 'package:inventario/features/gastos/domain/categoria_gasto.dart';
import 'package:inventario/features/salidas/data/repositorio_ventas_en_memoria.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';
import 'package:inventario/features/salidas/domain/venta.dart';

void main() {
  var ahora = DateTime(2026, 10, 27, 8);
  late RepositorioVentasEnMemoria ventas;
  late ControladorGastos gastos;
  late ControladorCaja caja;

  setUp(() async {
    ahora = DateTime(2026, 10, 27, 8);
    ventas = RepositorioVentasEnMemoria();
    gastos = ControladorGastos(
      RepositorioGastosEnMemoria(),
      ahora: () => ahora,
    );
    caja = ControladorCaja(
      RepositorioCajasEnMemoria(),
      ventas,
      gastos: gastos,
      ahora: () => ahora,
    );
    await caja.cargar();
  });

  tearDown(() {
    caja.dispose();
    gastos.dispose();
  });

  test('it starts closed and opens with its cash', () async {
    expect(caja.abierta, isNull);
    await caja.abrir(fondoDolares: 2000, fondoBolivares: 0);
    expect(caja.saldosDe(caja.abierta!), {MedioPago.efectivoDolares: 2000});
  });

  test('a sale read on load and an expense move the balance', () async {
    await caja.abrir(fondoDolares: 2000, fondoBolivares: 0);
    ahora = DateTime(2026, 10, 27, 10);
    await ventas.registrar(
      Venta(
        fecha: ahora,
        total: 500,
        pagos: const [PagoVenta(medio: MedioPago.efectivoDolares, monto: 500)],
      ),
    );
    await gastos.registrar(
      categoria: CategoriaGasto.transporte,
      medio: MedioPago.efectivoDolares,
      monto: 300,
    );
    await caja.cargar();
    expect(caja.saldosDe(caja.abierta!)[MedioPago.efectivoDolares], 2200);
  });

  test('closing keeps what was counted and leaves no till open', () async {
    await caja.abrir(fondoDolares: 2000, fondoBolivares: 0);
    ahora = DateTime(2026, 10, 27, 20);
    final cerrada = await caja.cerrar({
      MedioPago.efectivoDolares: 1900,
    }, nota: 'Faltan 1');
    expect(cerrada?.contado, {MedioPago.efectivoDolares: 1900});
    expect(caja.abierta, isNull);
    expect(caja.ultimaCerrada?.nota, 'Faltan 1');
  });
}
