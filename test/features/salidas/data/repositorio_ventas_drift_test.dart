import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/salidas/data/repositorio_ventas_drift.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';
import 'package:inventario/features/salidas/domain/venta.dart';

void main() {
  final mixta = Venta(
    fecha: DateTime(2026, 10, 27, 11, 5, 30, 123),
    total: 5327,
    tasa: 88730,
    pagos: const [
      PagoVenta(
        medio: MedioPago.pagoMovil,
        monto: 3000000,
        referencia: '004581',
      ),
      PagoVenta(medio: MedioPago.efectivoDolares, monto: 2000),
    ],
  );
  late BaseDatos db;
  late RepositorioVentasDrift repositorio;

  setUp(() {
    db = BaseDatos(NativeDatabase.memory());
    repositorio = RepositorioVentasDrift(db);
  });

  tearDown(() => db.close());

  test('a sale comes back with its payments in order', () async {
    final guardada = await repositorio.registrar(mixta);
    expect(guardada.id, isNotEmpty);
    expect(await repositorio.obtenerTodas(), [guardada]);
  });

  test('undoing it takes its payments too', () async {
    final guardada = await repositorio.registrar(mixta);
    await repositorio.quitar(guardada.id);
    expect(await repositorio.obtenerTodas(), isEmpty);
    expect(await db.select(db.pagosVenta).get(), isEmpty);
  });
}
