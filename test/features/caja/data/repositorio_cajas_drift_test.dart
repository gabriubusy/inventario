import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/caja/data/repositorio_cajas_drift.dart';
import 'package:inventario/features/caja/domain/caja.dart';
import 'package:inventario/features/gastos/data/repositorio_gastos_drift.dart';
import 'package:inventario/features/gastos/domain/categoria_gasto.dart';
import 'package:inventario/features/gastos/domain/gasto.dart';

void main() {
  late BaseDatos db;

  setUp(() => db = BaseDatos(NativeDatabase.memory()));

  tearDown(() => db.close());

  test('a till is kept open, then closed with its count', () async {
    final repositorio = RepositorioCajasDrift(db);
    final abierta = await repositorio.abrir(
      Caja(
        abierta: DateTime(2026, 10, 27, 8),
        fondoDolares: 2000,
        fondoBolivares: 500000,
      ),
    );
    expect(await repositorio.obtenerTodas(), [abierta]);
    final cerrada = abierta.cerradaCon(
      fecha: DateTime(2026, 10, 27, 20),
      contado: const {
        MedioPago.efectivoDolares: 1900,
        MedioPago.pagoMovil: 443115,
      },
      nota: 'Faltan \$ 1',
    );
    await repositorio.cerrar(cerrada);
    expect(await repositorio.obtenerTodas(), [cerrada]);
  });

  test('expenses are kept and can be taken back', () async {
    final repositorio = RepositorioGastosDrift(db);
    final gasto = await repositorio.crear(
      Gasto(
        fecha: DateTime(2026, 10, 27, 11),
        categoria: CategoriaGasto.servicios,
        medio: MedioPago.efectivoBolivares,
        monto: 180000,
        tasa: 88623,
        nota: 'Hielo',
      ),
    );
    expect(await repositorio.obtenerTodos(), [gasto]);
    await repositorio.quitar(gasto.id);
    expect(await repositorio.obtenerTodos(), isEmpty);
  });
}
