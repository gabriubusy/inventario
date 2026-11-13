import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/autenticacion/application/controlador_bloqueo.dart';
import 'package:inventario/features/autenticacion/data/almacen_bloqueo_en_memoria.dart';
import 'package:inventario/features/autenticacion/presentation/bloqueo_por_inactividad.dart';

void main() {
  late ControladorBloqueo bloqueo;
  var bloqueos = 0;

  setUp(() => bloqueos = 0);

  tearDown(() => bloqueo.dispose());

  Future<void> mostrar(WidgetTester tester, {required int minutos}) async {
    bloqueo = ControladorBloqueo(AlmacenBloqueoEnMemoria(minutos));
    await bloqueo.cargar();
    await tester.pumpWidget(
      MaterialApp(
        home: BloqueoPorInactividad(
          bloqueo: bloqueo,
          onBloquear: () => bloqueos++,
          child: const Scaffold(body: Center(child: Text('Inicio'))),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('with "Nunca" it never locks', (tester) async {
    await mostrar(tester, minutos: 0);
    await tester.pump(const Duration(hours: 2));
    expect(bloqueos, 0);
  });

  testWidgets('it locks after the chosen time with nobody using it', (
    tester,
  ) async {
    await mostrar(tester, minutos: 5);
    await tester.pump(const Duration(minutes: 4));
    expect(bloqueos, 0);
    await tester.pump(const Duration(minutes: 1, seconds: 1));
    expect(bloqueos, 1);
  });

  testWidgets('a click starts the wait again', (tester) async {
    await mostrar(tester, minutos: 5);
    await tester.pump(const Duration(minutes: 4));
    await tester.tap(find.text('Inicio'));
    await tester.pump(const Duration(minutes: 4));
    expect(bloqueos, 0);
    await tester.pump(const Duration(minutes: 2));
    expect(bloqueos, 1);
  });

  testWidgets('changing the setting takes effect at once', (tester) async {
    await mostrar(tester, minutos: 0);
    await bloqueo.cambiar(5);
    await tester.pump();
    await tester.pump(const Duration(minutes: 6));
    expect(bloqueos, 1);
  });
}
