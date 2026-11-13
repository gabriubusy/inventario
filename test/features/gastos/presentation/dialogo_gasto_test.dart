import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/gastos/data/repositorio_gastos_en_memoria.dart';
import 'package:inventario/features/gastos/domain/categoria_gasto.dart';
import 'package:inventario/features/gastos/presentation/dialogo_gasto.dart';

void main() {
  late ControladorGastos gastos;

  ControladorGastos conTasa(int? tasa) =>
      ControladorGastos(RepositorioGastosEnMemoria(), tasaDeHoy: () => tasa);

  setUp(() => gastos = conTasa(4000));

  tearDown(() => gastos.dispose());

  /// Opened the way the app does it, so the notice has a screen under it.
  Future<void> abrir(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => mostrarDialogoGasto(context, gastos: gastos),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> conAlt(WidgetTester tester, LogicalKeyboardKey tecla) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(tecla);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
  }

  Future<void> escribirMonto(WidgetTester tester, String monto) async {
    await tester.enterText(find.byType(TextField).first, monto);
    await tester.pumpAndSettle();
  }

  Future<void> registrar(WidgetTester tester) async {
    final boton = find.byWidgetPredicate(
      (w) => w is FilledButton,
      description: 'el botón de registrar',
    );
    await tester.ensureVisible(boton.first);
    await tester.pumpAndSettle();
    await tester.tap(boton.first);
    await tester.pumpAndSettle();
  }

  testWidgets('an expense in dollars is registered', (tester) async {
    await abrir(tester);
    await escribirMonto(tester, '5');
    await registrar(tester);
    expect(gastos.todos, hasLength(1));
    expect(gastos.todos.single.monto, 500);
    expect(find.textContaining('Gasto registrado'), findsOneWidget);
  });

  testWidgets('Alt+W turns it into income', (tester) async {
    await abrir(tester);
    await conAlt(tester, LogicalKeyboardKey.keyW);
    await escribirMonto(tester, '10');
    await registrar(tester);
    expect(gastos.todos.single.esIngreso, isTrue);
  });

  testWidgets('Alt+A picks the first category', (tester) async {
    await abrir(tester);
    await conAlt(tester, LogicalKeyboardKey.keyA);
    await escribirMonto(tester, '3');
    await registrar(tester);
    expect(gastos.todos.single.categoria, CategoriaGasto.servicios);
  });

  testWidgets('an amount in bolívares without a rate says so and keeps the '
      'window open', (tester) async {
    gastos.dispose();
    gastos = conTasa(null);
    await abrir(tester);
    await conAlt(tester, LogicalKeyboardKey.digit2);
    await escribirMonto(tester, '120');
    await registrar(tester);
    expect(gastos.todos, isEmpty);
    expect(find.textContaining('Falta la tasa de hoy'), findsOneWidget);
    expect(find.byType(DialogoGasto), findsOneWidget);
  });

  testWidgets('in bolívares with a rate it goes through', (tester) async {
    await abrir(tester);
    await conAlt(tester, LogicalKeyboardKey.digit2);
    await escribirMonto(tester, '120');
    await registrar(tester);
    expect(gastos.todos.single.tasa, 4000);
  });

  testWidgets('nothing is registered without an amount', (tester) async {
    await abrir(tester);
    await registrar(tester);
    expect(gastos.todos, isEmpty);
    expect(find.text('Escribe el monto'), findsOneWidget);
  });

  testWidgets('Deshacer takes the expense back out', (tester) async {
    await abrir(tester);
    await escribirMonto(tester, '5');
    await registrar(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Deshacer'));
    await tester.pumpAndSettle();
    expect(gastos.todos, isEmpty);
    expect(find.textContaining('deshecho'), findsOneWidget);
  });
}
