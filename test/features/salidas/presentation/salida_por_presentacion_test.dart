import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/presentation/dialogo_salida.dart';

void main() {
  late ControladorExistencias existencias;
  late ControladorSalidas salidas;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const [
        Producto(
          id: 'p1',
          nombre: 'Alimento para perro',
          categoria: Categoria.carnes,
          forma: FormaConteo.porKilo,
          minimo: 0,
          lotes: [LoteMarca(marca: 'Propia', cantidad: 26500)],
          presentaciones: [
            Presentacion(
              nombre: 'Saco',
              factor: 15000,
              precio: 3000,
              codigo: '7591234000011',
            ),
            Presentacion(
              nombre: 'Kilo',
              factor: 1000,
              precio: 220,
              predeterminada: true,
            ),
          ],
        ),
      ]),
    );
    await existencias.cargar();
    salidas = ControladorSalidas(existencias, tasaDeHoy: () => 1000);
  });

  tearDown(() {
    salidas.dispose();
    existencias.dispose();
  });

  int stock() => existencias.productos.single.cantidad;

  Future<void> abrir(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => unawaited(
                mostrarDialogoSalida(
                  context,
                  salidas: salidas,
                  existencias: existencias,
                  aBolivares: (dolares) => dolares * 10,
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  // Types into the focused field and presses Enter, as a scanner does.
  Future<void> escribirYEnter(WidgetTester tester, String texto) async {
    tester.testTextInput.enterText(texto);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  // F10, then Enter on the empty amount: paid exactly.
  Future<void> cobrarExacto(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.f10);
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  testWidgets('the default pack comes chosen: 2,5 kilos sold loose', (
    tester,
  ) async {
    await abrir(tester);
    await escribirYEnter(tester, 'perro');
    tester.testTextInput.enterText('2,5');
    await tester.pump();
    expect(find.text(r'$ 5,50'), findsOneWidget);
    expect(
      find.text('Total: 26,5 kg (1 saco + 11,5 kg) → 24 kg (1 saco + 9 kg)'),
      findsOneWidget,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Propia · 2,5 kilo'), findsOneWidget);
    await cobrarExacto(tester);
    expect(stock(), 24000);
  });

  testWidgets('scanning the sack code sells by the sack', (tester) async {
    await abrir(tester);
    await escribirYEnter(tester, '7591234000011');
    tester.testTextInput.enterText('1');
    await tester.pump();
    expect(find.text(r'$ 30,00'), findsWidgets);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Propia · 1 saco'), findsOneWidget);
    await cobrarExacto(tester);
    expect(stock(), 11500);
  });

  testWidgets('Alt+1 switches to the sack and checks there is enough', (
    tester,
  ) async {
    await abrir(tester);
    await escribirYEnter(tester, 'perro');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    await escribirYEnter(tester, '2');
    expect(find.text('Solo hay 1,766 sacos'), findsOneWidget);
    expect(stock(), 26500);
  });
}
