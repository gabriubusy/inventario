import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/data/almacen_tasa_en_memoria.dart';
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
}
