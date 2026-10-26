import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/entradas/presentation/dialogo_entrada.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  late ControladorExistencias existencias;
  late ControladorEntradas entradas;

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
              proveedor: 'Distribuidora 1',
              piezas: 10,
              cantidad: 8200,
            ),
            LoteMarca(
              marca: 'Marca B',
              proveedor: 'Distribuidora 2',
              piezas: 14,
              cantidad: 11000,
            ),
          ],
        ),
        Producto(
          id: 'p2',
          nombre: 'Carne molida',
          categoria: Categoria.carnes,
          forma: FormaConteo.porKilo,
          minimo: 8000,
        ),
      ]),
    );
    await existencias.cargar();
    entradas = ControladorEntradas(existencias);
  });

  tearDown(() {
    entradas.dispose();
    existencias.dispose();
  });

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
                mostrarDialogoEntrada(
                  context,
                  entradas: entradas,
                  existencias: existencias,
                  proveedores: const ['Distribuidora 1', 'Lácteos 1'],
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

  Finder campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

  Producto producto(String id) =>
      existencias.productos.firstWhere((p) => p.id == id);

  Future<void> elegirProducto(WidgetTester tester, String texto, String nombre) async {
    await tester.enterText(campo('Producto'), texto);
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, nombre));
    await tester.pumpAndSettle();
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

  Future<void> registrar(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar'));
    await tester.pumpAndSettle();
  }

  testWidgets('adds the pieces and weight to the first brand', (tester) async {
    await abrir(tester);
    await elegirProducto(tester, 'queso', 'Queso blanco duro');
    await tester.enterText(campo('Piezas'), '6');
    await tester.enterText(campo('Peso'), '4,9');
    await tester.pump();
    expect(
      find.text('Marca A quedará: 10 piezas · 8,2 kg → 16 piezas · 13,1 kg'),
      findsOneWidget,
    );

    await registrar(tester);
    final lote = producto('p1').lotes.first;
    expect(lote.piezas, 16);
    expect(lote.cantidad, 13100);
    expect(find.byType(DialogoEntrada), findsNothing);
    expect(
      find.textContaining('Entrada registrada · Queso blanco duro'),
      findsOneWidget,
    );
  });

  testWidgets('Alt+2 picks the second brand', (tester) async {
    await abrir(tester);
    await elegirProducto(tester, 'queso', 'Queso blanco duro');
    await conTecla(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.digit2);
    await tester.enterText(campo('Piezas'), '1');
    await tester.enterText(campo('Peso'), '0,8');
    await registrar(tester);
    expect(producto('p1').lotes.last.piezas, 15);
  });

  testWidgets('a new brand becomes its own lot', (tester) async {
    await abrir(tester);
    await elegirProducto(tester, 'molida', 'Carne molida');
    await tester.enterText(campo('Marca'), 'Propia');
    await tester.enterText(campo('Proveedor'), 'Frigorífico 1');
    await tester.enterText(campo('Cantidad'), '12,5');
    await registrar(tester);
    expect(
      producto('p2').lotes.single,
      const LoteMarca(marca: 'Propia', proveedor: 'Frigorífico 1', cantidad: 12500),
    );
  });

  testWidgets('asks for a product from the list', (tester) async {
    await abrir(tester);
    await registrar(tester);
    expect(find.text('Elige un producto de la lista'), findsOneWidget);
  });

  testWidgets('zero is not an entry', (tester) async {
    await abrir(tester);
    await elegirProducto(tester, 'queso', 'Queso blanco duro');
    await tester.enterText(campo('Piezas'), '0');
    await tester.enterText(campo('Peso'), '2');
    await registrar(tester);
    expect(find.text('Mayor que 0'), findsOneWidget);
    expect(producto('p1').lotes.first.piezas, 10);
  });

  testWidgets('Ctrl+Enter registers and leaves the window ready', (
    tester,
  ) async {
    await abrir(tester);
    await elegirProducto(tester, 'molida', 'Carne molida');
    await tester.enterText(campo('Marca'), 'Propia');
    await tester.enterText(campo('Cantidad'), '3');
    await conTecla(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.enter,
    );
    expect(producto('p2').cantidad, 3000);
    expect(find.byType(DialogoEntrada), findsOneWidget);
    expect(campo('Producto'), findsOneWidget);
  });

  testWidgets('Deshacer puts the stock back', (tester) async {
    await abrir(tester);
    await elegirProducto(tester, 'queso', 'Queso blanco duro');
    await tester.enterText(campo('Piezas'), '6');
    await tester.enterText(campo('Peso'), '4,9');
    await registrar(tester);
    await tester.tap(find.text('Deshacer (Ctrl+Z)'));
    await tester.pumpAndSettle();
    expect(producto('p1').lotes.first.piezas, 10);
    expect(find.text('Entrada deshecha'), findsOneWidget);
  });
}
