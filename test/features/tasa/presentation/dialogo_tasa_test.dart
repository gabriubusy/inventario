import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/data/almacen_tasa_en_memoria.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';
import 'package:inventario/features/tasa/presentation/dialogo_tasa.dart';

void main() {
  final ayer = DateTime(2026, 10, 29, 9);
  final hoy = DateTime(2026, 10, 30, 9);
  late ControladorTasa tasa;

  setUp(() async {
    tasa = ControladorTasa(
      AlmacenTasaEnMemoria(TasaCambio(bolivaresPorDolar: 3650, fecha: ayer)),
      ahora: () => hoy,
    );
    await tasa.cargar();
  });

  tearDown(() => tasa.dispose());

  Future<void> abrir(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(body: DialogoTasa(controlador: tasa)),
      ),
    );
    await tester.pump();
  }

  Future<void> enter(WidgetTester tester) async {
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  testWidgets('the last rate comes written, ready to keep or replace', (
    tester,
  ) async {
    await abrir(tester);
    expect(find.text('36,50'), findsOneWidget);
    await enter(tester);
    expect(tasa.esDeHoy, isTrue);
  });

  testWidgets('a big jump asks for a second Enter before saving', (
    tester,
  ) async {
    await abrir(tester);
    tester.testTextInput.enterText('3650');
    await tester.pump();
    await enter(tester);
    expect(tasa.esDeHoy, isFalse);
    expect(find.textContaining('¿Está bien escrita?'), findsOneWidget);
    await enter(tester);
    expect(tasa.tasa?.bolivaresPorDolar, 365000);
  });
}
