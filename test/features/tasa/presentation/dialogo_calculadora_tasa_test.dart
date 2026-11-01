import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/data/almacen_tasa_en_memoria.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';
import 'package:inventario/features/tasa/presentation/dialogo_calculadora_tasa.dart';

void main() {
  final hoy = DateTime(2026, 10, 31, 9);
  late ControladorTasa tasa;

  setUp(() async {
    tasa = ControladorTasa(
      AlmacenTasaEnMemoria(TasaCambio(bolivaresPorDolar: 90000, fecha: hoy)),
      ahora: () => hoy,
    );
    await tasa.cargar();
  });

  tearDown(() => tasa.dispose());

  Future<void> abrir(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(body: DialogoCalculadoraTasa(controlador: tasa)),
      ),
    );
    await tester.pump();
  }

  Finder campo(String etiqueta) => find.widgetWithText(TextField, etiqueta);

  testWidgets('dollars typed come out in bolívares', (tester) async {
    await abrir(tester);
    await tester.enterText(campo('Dólares'), '2,5');
    await tester.pump();
    expect(find.text('2.250,00'), findsOneWidget);
  });

  testWidgets('bolívares typed come out in dollars', (tester) async {
    await abrir(tester);
    await tester.enterText(campo('Bolívares'), '4500');
    await tester.pump();
    expect(find.text('5,00'), findsOneWidget);
  });

  testWidgets('clearing one field clears the other', (tester) async {
    await abrir(tester);
    await tester.enterText(campo('Dólares'), '10');
    await tester.pump();
    await tester.enterText(campo('Dólares'), '');
    await tester.pump();
    expect(find.text('9.000,00'), findsNothing);
  });
}
