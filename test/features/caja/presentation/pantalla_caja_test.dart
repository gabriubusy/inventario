import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/caja/application/controlador_caja.dart';
import 'package:inventario/features/caja/data/repositorio_cajas_en_memoria.dart';
import 'package:inventario/features/caja/presentation/pantalla_caja.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/gastos/data/repositorio_gastos_en_memoria.dart';
import 'package:inventario/features/gastos/presentation/dialogo_gasto.dart';
import 'package:inventario/features/salidas/data/repositorio_ventas_en_memoria.dart';

void main() {
  late ControladorGastos gastos;
  late ControladorCaja caja;

  setUp(() {
    gastos = ControladorGastos(RepositorioGastosEnMemoria());
    caja = ControladorCaja(
      RepositorioCajasEnMemoria(),
      RepositorioVentasEnMemoria(),
      gastos: gastos,
    );
  });

  tearDown(() {
    caja.dispose();
    gastos.dispose();
  });

  Future<void> mostrar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaCaja(caja: caja, gastos: gastos),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> conControl(WidgetTester tester, LogicalKeyboardKey t) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(t);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
  }

  testWidgets('opening shows the cash there should be', (tester) async {
    await mostrar(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Efectivo en dólares'),
      '20',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Abrir caja'));
    await tester.pumpAndSettle();
    expect(find.text('Debería haber ahora'), findsOneWidget);
    expect(find.text(r'$ 20,00'), findsWidgets);
  });

  testWidgets('an expense with Ctrl+G comes off the cash', (tester) async {
    await caja.abrir(fondoDolares: 2000, fondoBolivares: 0);
    await mostrar(tester);
    await conControl(tester, LogicalKeyboardKey.keyG);
    expect(find.byType(DialogoGasto), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, r'Efectivo $'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, r'Monto en $'), '5');
    final registrar = find.widgetWithText(FilledButton, 'Registrar gasto');
    await tester.ensureVisible(registrar);
    await tester.pumpAndSettle();
    await tester.tap(registrar);
    await tester.pumpAndSettle();
    expect(gastos.todos, hasLength(1));
    expect(find.byType(DialogoGasto), findsNothing);
    expect(find.text(r'$ 15,00'), findsWidgets);
  });

  testWidgets('Ctrl+S closes with the count and tells the difference', (
    tester,
  ) async {
    await caja.abrir(fondoDolares: 2000, fondoBolivares: 0);
    await mostrar(tester);
    await conControl(tester, LogicalKeyboardKey.keyS);
    expect(find.text('Cuadra'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Contado'), '19');
    await tester.pump();
    expect(find.text(r'Faltan $ 1,00'), findsOneWidget);
    await conControl(tester, LogicalKeyboardKey.keyS);
    expect(caja.abierta, isNull);
    expect(find.text('Abrir la caja de hoy'), findsOneWidget);
  });
}
