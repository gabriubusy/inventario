import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/regla_precio.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/presentation/dialogo_salida.dart';

void main() {
  late ControladorExistencias existencias;
  late ControladorSalidas salidas;
  late ControladorMovimientos movimientos;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const [
        Producto(
          id: 'p1',
          nombre: 'Queso blanco duro',
          categoria: Categoria.quesos,
          forma: FormaConteo.piezasYKilos,
          minimo: 5,
          lotes: [
            LoteMarca(
              marca: 'Marca A',
              piezas: 10,
              cantidad: 8200,
              precio: 520,
            ),
            LoteMarca(
              marca: 'Marca B',
              piezas: 14,
              piezaAbierta: true,
              cantidad: 11000,
              precio: 560,
            ),
          ],
        ),
        Producto(
          id: 'p2',
          nombre: 'Carne molida',
          categoria: Categoria.carnes,
          forma: FormaConteo.porKilo,
          minimo: 8000,
          lotes: [LoteMarca(marca: 'Propia', cantidad: 3800, precio: 620)],
          reglas: {ListaPrecio.mayor: PrecioFijo(500)},
        ),
      ]),
    );
    await existencias.cargar();
    movimientos = ControladorMovimientos(RepositorioMovimientosEnMemoria());
    salidas = ControladorSalidas(
      existencias,
      movimientos: movimientos,
      tasaDeHoy: () => 4000,
    );
  });

  tearDown(() {
    salidas.dispose();
    existencias.dispose();
  });

  Producto guardado(String id) =>
      existencias.productos.firstWhere((p) => p.id == id);

  Future<void> abrir(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
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
                  aBolivares: (dolares) => dolares * 40,
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

  // Types the product and takes the first suggestion, as the user would.
  Future<void> elegir(WidgetTester tester, String texto) async {
    tester.testTextInput.enterText(texto);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();
  }

  // Types into whichever field has the focus, then presses Enter there.
  Future<void> escribirYEnter(WidgetTester tester, String texto) async {
    tester.testTextInput.enterText(texto);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  Future<void> conAlt(WidgetTester tester, LogicalKeyboardKey tecla) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(tecla);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
  }

  // F10, then Enter on the empty amount: paid exactly, in the last way.
  Future<void> cobrarExacto(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.f10);
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  testWidgets('Enter puts the piece in the ticket and F10 charges it', (
    tester,
  ) async {
    await abrir(tester);
    await elegir(tester, 'queso');
    // The fullest brand comes chosen and the focus waits on the weight.
    await escribirYEnter(tester, '0,84');
    expect(guardado('p1').lotes.last.piezas, 14);
    expect(find.text('Marca B · 1 pieza, 0,84 kg'), findsOneWidget);

    await cobrarExacto(tester);
    final lote = guardado('p1').lotes.last;
    expect(lote.piezas, 13);
    expect(lote.cantidad, 10160);
    expect(find.byType(DialogoSalida), findsNothing);
    expect(find.textContaining('Venta registrada'), findsOneWidget);
  });

  testWidgets('one ticket sells several products together', (tester) async {
    await abrir(tester);
    await elegir(tester, 'queso');
    await escribirYEnter(tester, '0,84');
    await elegir(tester, 'molida');
    await escribirYEnter(tester, '1');
    expect(find.text('Ticket · 2 productos'), findsOneWidget);
    await cobrarExacto(tester);
    expect(guardado('p1').lotes.last.piezas, 13);
    expect(guardado('p2').cantidad, 2800);
  });

  testWidgets('grams can be typed: "250 g" sells a quarter kilo', (
    tester,
  ) async {
    await abrir(tester);
    await elegir(tester, 'molida');
    await escribirYEnter(tester, '250 g');
    expect(find.text('Propia · 0,25 kg'), findsOneWidget);
    expect(salidas.ticketEnCurso.total, 155);
  });

  testWidgets('a second line only gets what the first one left', (
    tester,
  ) async {
    await abrir(tester);
    await elegir(tester, 'molida');
    await escribirYEnter(tester, '3');
    await elegir(tester, 'molida');
    await escribirYEnter(tester, '1');
    expect(find.text('Solo hay 0,8 kg'), findsOneWidget);
  });

  testWidgets('Alt+Supr takes the last line out and Alt+Z brings it back', (
    tester,
  ) async {
    await abrir(tester);
    await elegir(tester, 'molida');
    await escribirYEnter(tester, '1');
    await conAlt(tester, LogicalKeyboardKey.delete);
    expect(
      find.text('El ticket está vacío: agrega productos con Enter.'),
      findsOneWidget,
    );
    await conAlt(tester, LogicalKeyboardKey.keyZ);
    expect(find.text('Propia · 1 kg'), findsOneWidget);
  });

  testWidgets('Alt+L reprices the ticket and the sale keeps that list', (
    tester,
  ) async {
    await abrir(tester);
    await elegir(tester, 'molida');
    await escribirYEnter(tester, '2');
    expect(salidas.ticketEnCurso.total, 1240);
    await conAlt(tester, LogicalKeyboardKey.keyL);
    expect(salidas.ticketEnCurso.lista, ListaPrecio.mayor);
    expect(salidas.ticketEnCurso.total, 1000);

    await cobrarExacto(tester);
    expect(movimientos.todos.last.importe, 1000);
    expect(salidas.ticketEnCurso.lista, ListaPrecio.detal);
  });

  testWidgets('Ctrl+1 picks the most sold product', (tester) async {
    await salidas.registrar('p2', const Salida(marca: 'Propia', cantidad: 500));
    await abrir(tester);
    expect(find.text('Más vendidos'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    await escribirYEnter(tester, '1');
    expect(find.text('Propia · 1 kg'), findsOneWidget);
  });

  testWidgets('Esc closes the window but keeps the ticket', (tester) async {
    await abrir(tester);
    await elegir(tester, 'molida');
    await escribirYEnter(tester, '1');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoSalida), findsNothing);
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Propia · 1 kg'), findsOneWidget);
  });

  testWidgets('shows the amount in dollars and bolívares while typing', (
    tester,
  ) async {
    await abrir(tester);
    await elegir(tester, 'molida');
    tester.testTextInput.enterText('0,75');
    await tester.pump();
    expect(find.text(r'$ 4,65'), findsOneWidget);
    expect(find.text('186,00 Bs'), findsOneWidget);
  });

  testWidgets('Alt+K sells by weight and warns when a piece is opened', (
    tester,
  ) async {
    await abrir(tester);
    await elegir(tester, 'queso');
    await conAlt(tester, LogicalKeyboardKey.digit1);
    await conAlt(tester, LogicalKeyboardKey.keyK);
    tester.testTextInput.enterText('0,75');
    await tester.pump();
    expect(
      find.text('Marca A no tiene pieza abierta: esta venta abre 1 pieza.'),
      findsOneWidget,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await cobrarExacto(tester);
    final lote = guardado('p1').lotes.first;
    expect(lote.piezas, 9);
    expect(lote.piezaAbierta, isTrue);
  });

  testWidgets('more than there is is not registered', (tester) async {
    await abrir(tester);
    await elegir(tester, 'molida');
    await escribirYEnter(tester, '5');
    expect(find.text('Solo hay 3,8 kg'), findsOneWidget);
    expect(guardado('p2').cantidad, 3800);
    expect(find.byType(DialogoSalida), findsOneWidget);
  });

  testWidgets('Deshacer puts the stock back', (tester) async {
    await abrir(tester);
    await elegir(tester, 'molida');
    await escribirYEnter(tester, '1');
    await cobrarExacto(tester);
    expect(guardado('p2').cantidad, 2800);
    await tester.tap(find.text('Deshacer (Ctrl+Z)'));
    await tester.pumpAndSettle();
    expect(guardado('p2').cantidad, 3800);
  });
}
