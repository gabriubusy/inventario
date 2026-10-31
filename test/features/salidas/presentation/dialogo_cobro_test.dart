import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';
import 'package:inventario/features/salidas/domain/resultado_cobro.dart';
import 'package:inventario/features/salidas/domain/venta.dart';
import 'package:inventario/features/salidas/presentation/dialogo_cobro.dart';

void main() {
  List<PagoVenta>? cobrado;

  Future<void> abrir(WidgetTester tester) async {
    cobrado = null;
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: DialogoCobro(
            total: 5327,
            tasa: 88730,
            medioInicial: MedioPago.efectivoDolares,
            onCobrar: (pagos) async {
              cobrado = pagos;
              return VentaCobrada(
                Venta(fecha: DateTime(2026), total: 5327, pagos: pagos),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> conTecla(
    WidgetTester tester,
    LogicalKeyboardKey modificador,
    LogicalKeyboardKey tecla,
  ) async {
    await tester.sendKeyDownEvent(modificador);
    await tester.sendKeyEvent(tecla);
    await tester.sendKeyUpEvent(modificador);
    await tester.pumpAndSettle();
  }

  Future<void> escribir(WidgetTester tester, String texto) async {
    tester.testTextInput.enterText(texto);
    await tester.pump();
  }

  Future<void> enter(WidgetTester tester) async {
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  testWidgets('cash in dollars shows the change in \$ and Bs', (tester) async {
    await abrir(tester);
    await escribir(tester, '60');
    expect(find.text(r'$ 6,73'), findsOneWidget);
    expect(find.text('o 5.971,53 Bs'), findsOneWidget);
    await enter(tester);
    expect(cobrado, [
      const PagoVenta(medio: MedioPago.efectivoDolares, monto: 6000),
    ]);
  });

  testWidgets('an empty amount pays exactly, in the chosen currency', (
    tester,
  ) async {
    await abrir(tester);
    await conTecla(
      tester,
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.digit3,
    );
    await enter(tester);
    expect(cobrado, [
      const PagoVenta(medio: MedioPago.pagoMovil, monto: 4726647),
    ]);
  });

  testWidgets('Ctrl+M adds a payment and the rest is paid another way', (
    tester,
  ) async {
    await abrir(tester);
    await conTecla(
      tester,
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.digit3,
    );
    await escribir(tester, '30000');
    await conTecla(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyM,
    );
    expect(find.text('Pago móvil · 30.000,00 Bs'), findsOneWidget);
    expect(find.text(r'$ 19,46'), findsOneWidget);

    await conTecla(
      tester,
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.digit1,
    );
    await escribir(tester, '20');
    expect(find.text(r'$ 0,54'), findsOneWidget);
    await enter(tester);
    expect(cobrado, [
      const PagoVenta(medio: MedioPago.pagoMovil, monto: 3000000),
      const PagoVenta(medio: MedioPago.efectivoDolares, monto: 2000),
    ]);
  });

  testWidgets('Enter on a short amount adds it and asks for the rest', (
    tester,
  ) async {
    await abrir(tester);
    await escribir(tester, '50');
    expect(find.text('Falta'), findsOneWidget);
    expect(find.text('Añadir este pago'), findsOneWidget);
    await enter(tester);
    expect(cobrado, isNull);
    expect(find.text(r'Efectivo $ · $ 50,00'), findsOneWidget);
    expect(find.text(r'$ 3,27'), findsOneWidget);
    expect(find.textContaining('o 2.901,47 Bs'), findsOneWidget);
  });
}
