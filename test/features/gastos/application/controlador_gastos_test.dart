import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/gastos/data/repositorio_gastos_en_memoria.dart';
import 'package:inventario/features/gastos/domain/categoria_gasto.dart';
import 'package:inventario/features/gastos/domain/gasto.dart';
import 'package:inventario/features/gastos/domain/resultado_gasto.dart';

void main() {
  final hoy = DateTime(2026, 11, 12, 10);
  late RepositorioGastosEnMemoria repositorio;

  setUp(() => repositorio = RepositorioGastosEnMemoria());

  ControladorGastos crear({int? tasa}) =>
      ControladorGastos(repositorio, tasaDeHoy: () => tasa, ahora: () => hoy);

  Future<ResultadoGasto> registrar(
    ControladorGastos controlador, {
    MedioPago medio = MedioPago.efectivoDolares,
    int monto = 1500,
    CategoriaGasto categoria = CategoriaGasto.servicios,
  }) => controlador.registrar(
    categoria: categoria,
    medio: medio,
    monto: monto,
    nota: '',
  );

  Gasto gastoDe(ResultadoGasto resultado) =>
      (resultado as GastoRegistrado).gasto;

  test(
    'an expense in dollars is stored with the day and its category',
    () async {
      final controlador = crear();
      final resultado = await registrar(controlador);
      final gasto = gastoDe(resultado);
      expect(gasto.fecha, hoy);
      expect(gasto.categoria, CategoriaGasto.servicios);
      expect(gasto.monto, 1500);
      expect(gasto.enDolares, 1500);
      expect(controlador.todos, [gasto]);
    },
  );

  test("an amount in bolívares keeps the day's rate", () async {
    final controlador = crear(tasa: 4000);
    final gasto = gastoDe(
      await registrar(
        controlador,
        medio: MedioPago.efectivoBolivares,
        monto: 12000,
      ),
    );
    expect(gasto.tasa, 4000);
    expect(gasto.enDolares, 300);
  });

  test('an amount in bolívares without a rate is not stored', () async {
    final controlador = crear();
    final resultado = await registrar(
      controlador,
      medio: MedioPago.efectivoBolivares,
      monto: 12000,
    );
    expect(resultado, isA<GastoSinTasa>());
    expect(controlador.todos, isEmpty);
    expect(await repositorio.obtenerTodos(), isEmpty);
  });

  test('without a rate an amount in dollars still goes through', () async {
    final controlador = crear();
    final resultado = await registrar(controlador, medio: MedioPago.zelle);
    expect(resultado, isA<GastoRegistrado>());
  });

  test('income goes in the list as income', () async {
    final controlador = crear();
    final gasto = gastoDe(
      await registrar(controlador, categoria: CategoriaGasto.aporteDueno),
    );
    expect(gasto.esIngreso, isTrue);
  });

  test('undoing the last expense takes it out', () async {
    final controlador = crear();
    final gasto = gastoDe(await registrar(controlador));
    expect(await controlador.deshacer(gasto), isTrue);
    expect(controlador.todos, isEmpty);
    expect(await repositorio.obtenerTodos(), isEmpty);
  });

  test('it is not undone twice', () async {
    final controlador = crear();
    final gasto = gastoDe(await registrar(controlador));
    await controlador.deshacer(gasto);
    expect(await controlador.deshacer(gasto), isFalse);
  });

  test('an expense with another one after it is no longer undone', () async {
    final controlador = crear();
    final primero = gastoDe(await registrar(controlador));
    final segundo = gastoDe(await registrar(controlador, monto: 2500));
    expect(await controlador.deshacer(primero), isFalse);
    expect(controlador.todos, hasLength(2));
    expect(await controlador.deshacer(segundo), isTrue);
  });

  test('the list comes newest first', () async {
    final controlador = ControladorGastos(
      RepositorioGastosEnMemoria([
        Gasto(
          fecha: DateTime(2026, 11, 10),
          categoria: CategoriaGasto.sueldos,
          medio: MedioPago.efectivoDolares,
          monto: 100,
        ),
        Gasto(
          fecha: DateTime(2026, 11, 11),
          categoria: CategoriaGasto.alquiler,
          medio: MedioPago.efectivoDolares,
          monto: 200,
        ),
      ]),
      ahora: () => hoy,
    );
    await controlador.cargar();
    expect(controlador.todos.map((g) => g.categoria), [
      CategoriaGasto.alquiler,
      CategoriaGasto.sueldos,
    ]);
  });
}
