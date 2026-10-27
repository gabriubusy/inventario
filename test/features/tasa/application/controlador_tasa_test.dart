import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/data/almacen_tasa_en_memoria.dart';
import 'package:inventario/features/tasa/domain/fuente_tasa.dart';
import 'package:inventario/features/tasa/domain/origen_tasa.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';

void main() {
  final hoy = DateTime(2026, 10, 25, 10);
  final deAyer = TasaCambio(
    bolivaresPorDolar: 3960,
    fecha: DateTime(2026, 10, 24),
  );

  ControladorTasa crear([TasaCambio? guardada]) =>
      ControladorTasa(AlmacenTasaEnMemoria(guardada), ahora: () => hoy);

  test('without any rate there are no bolívares', () async {
    final controlador = crear();
    await controlador.cargar();
    expect(controlador.tasa, isNull);
    expect(controlador.esDeHoy, isFalse);
    expect(controlador.aBolivares(980), isNull);
  });

  test("yesterday's rate still prices, but is not today's", () async {
    final controlador = crear(deAyer);
    await controlador.cargar();
    expect(controlador.esDeHoy, isFalse);
    expect(controlador.aBolivares(980), 38808);
  });

  test("saving sets today's rate and keeps it for the next start", () async {
    final almacen = AlmacenTasaEnMemoria(deAyer);
    final controlador = ControladorTasa(almacen, ahora: () => hoy);
    await controlador.guardar(4000);
    expect(controlador.esDeHoy, isTrue);
    expect(controlador.aBolivares(980), 39200);
    expect(
      await almacen.leer(),
      TasaCambio(bolivaresPorDolar: 4000, fecha: hoy),
    );
  });

  test('a rate typed by hand is compared with the last saved day', () async {
    final controlador = crear(deAyer);
    await controlador.cargar();
    await controlador.guardar(4000);
    expect(controlador.tasa?.anterior, 3960);
    // A same-day correction still compares with yesterday.
    await controlador.guardar(4010);
    expect(controlador.tasa?.anterior, 3960);
  });

  group('from the internet', () {
    ControladorTasa conFuente(
      ResultadoConsultaTasa respuesta, {
      TasaCambio? guardada,
      List<int>? consultas,
    }) => ControladorTasa(
      AlmacenTasaEnMemoria(guardada),
      fuente: _FuenteFija(respuesta, consultas ?? []),
      ahora: () => hoy,
    );

    test("saves today's BCV rate when there is none for today", () async {
      final controlador = conFuente(
        const TasaObtenida(88623),
        guardada: deAyer,
      );
      await controlador.cargar();
      await controlador.actualizarDesdeInternet();
      expect(controlador.esDeHoy, isTrue);
      expect(controlador.tasa?.bolivaresPorDolar, 88623);
      expect(controlador.tasa?.origen, OrigenTasa.bcv);
    });

    test("does not ask again once today's rate is in", () async {
      final consultas = <int>[];
      final controlador = conFuente(
        const TasaObtenida(88623),
        guardada: TasaCambio(bolivaresPorDolar: 4000, fecha: hoy),
        consultas: consultas,
      );
      await controlador.cargar();
      await controlador.actualizarDesdeInternet();
      expect(consultas, isEmpty);
      expect(controlador.tasa?.bolivaresPorDolar, 4000);
    });

    test('keeps the previous BCV rate to show the change', () async {
      final controlador = conFuente(
        const TasaObtenida(88623, anterior: 88475),
        guardada: deAyer,
      );
      await controlador.cargar();
      await controlador.actualizarDesdeInternet();
      expect(controlador.tasa?.variacion, 17);
    });

    test('keeps the last rate when the service is unreachable', () async {
      final controlador = conFuente(const TasaNoDisponible(), guardada: deAyer);
      await controlador.cargar();
      await controlador.actualizarDesdeInternet();
      expect(controlador.tasa, deAyer);
      expect(controlador.esDeHoy, isFalse);
      expect(controlador.consultando, isFalse);
    });

    test('asks the user only after the internet failed', () async {
      final controlador = conFuente(const TasaNoDisponible(), guardada: deAyer);
      await controlador.cargar();
      expect(controlador.hayQuePedirla, isFalse);
      await controlador.actualizarDesdeInternet();
      expect(controlador.hayQuePedirla, isTrue);
    });

    test('does not ask when the internet brought it', () async {
      final controlador = conFuente(
        const TasaObtenida(88623),
        guardada: deAyer,
      );
      await controlador.cargar();
      await controlador.actualizarDesdeInternet();
      expect(controlador.hayQuePedirla, isFalse);
    });
  });

  test('without a source it asks as soon as the saved one is read', () async {
    final controlador = crear(deAyer);
    expect(controlador.hayQuePedirla, isFalse);
    await controlador.cargar();
    expect(controlador.hayQuePedirla, isTrue);
  });
}

/// Answers every call with the same result and counts the calls.
class _FuenteFija implements FuenteTasa {
  _FuenteFija(this._respuesta, this._consultas);

  final ResultadoConsultaTasa _respuesta;
  final List<int> _consultas;

  @override
  Future<ResultadoConsultaTasa> consultar() async {
    _consultas.add(1);
    return _respuesta;
  }
}
