import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/data/almacen_tasa_en_memoria.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';
import 'package:inventario/features/tasa/presentation/dialogo_tasa.dart';
import 'package:inventario/features/tasa/presentation/pedir_tasa_si_falta.dart';

void main() {
  final deAyer = TasaCambio(
    bolivaresPorDolar: 3960,
    fecha: DateTime(2026, 10, 24),
  );
  var ahora = DateTime(2026, 10, 25, 10);
  late ControladorTasa tasa;

  setUp(() async {
    ahora = DateTime(2026, 10, 25, 10);
    tasa = ControladorTasa(AlmacenTasaEnMemoria(deAyer), ahora: () => ahora);
  });

  tearDown(() => tasa.dispose());

  Future<void> mostrar(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PedirTasaSiFalta(
          tasa: tasa,
          cada: const Duration(seconds: 1),
          child: const Scaffold(body: Text('Inicio')),
        ),
      ),
    );
    await tasa.cargar();
    await tester.pumpAndSettle();
  }

  Future<void> cerrar(WidgetTester tester) async {
    Navigator.of(tester.element(find.byType(DialogoTasa))).pop();
    await tester.pumpAndSettle();
  }

  testWidgets('without a rate for today it asks on entering', (tester) async {
    await mostrar(tester);
    expect(find.byType(DialogoTasa), findsOneWidget);
  });

  testWidgets('closed once, it is not asked again the same day', (
    tester,
  ) async {
    await mostrar(tester);
    await cerrar(tester);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoTasa), findsNothing);
  });

  testWidgets('it asks again when the day changes', (tester) async {
    await mostrar(tester);
    await tester.enterText(find.byType(TextField).first, '40,00');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoTasa), findsNothing);
    expect(tasa.esDeHoy, isTrue);

    ahora = DateTime(2026, 10, 26, 8);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoTasa), findsOneWidget);
  });
}
