import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/data/repositorio_compras_en_memoria.dart';
import 'package:inventario/features/compras/presentation/dialogo_compra.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  late ControladorExistencias existencias;
  late ControladorCompras compras;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const [
        Producto(
          id: 'm',
          nombre: 'Carne molida',
          categoria: Categoria.carnes,
          forma: FormaConteo.porKilo,
          minimo: 8000,
          lotes: [
            LoteMarca(
              marca: 'Propia',
              proveedor: 'Frigorífico 1',
              cantidad: 3800,
              costo: 450,
            ),
          ],
        ),
        Producto(
          id: 'q',
          nombre: 'Queso blanco duro',
          categoria: Categoria.quesos,
          forma: FormaConteo.piezasYKilos,
          minimo: 5,
        ),
      ]),
    );
    await existencias.cargar();
    compras = ControladorCompras(
      RepositorioComprasEnMemoria(),
      existencias,
      tasaDeHoy: () => 88623,
    );
  });

  tearDown(() {
    compras.dispose();
    existencias.dispose();
  });

  Future<void> abrir(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => unawaited(
                mostrarDialogoCompra(
                  context,
                  compras: compras,
                  existencias: existencias,
                  proveedorInicial: 'Frigorífico 1',
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

  Future<void> elegir(WidgetTester tester, String texto, String nombre) async {
    await tester.enterText(campo('Producto'), texto);
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, nombre));
    await tester.pumpAndSettle();
  }

  testWidgets('the supplier\'s brand comes with its last cost', (tester) async {
    await abrir(tester);
    await elegir(tester, 'molida', 'Carne molida');
    final costo = tester.widget<TextFormField>(campo('Costo /kg'));
    expect(costo.controller?.text, '4,50');
  });

  testWidgets('two products on credit make one invoice', (tester) async {
    await abrir(tester);
    await elegir(tester, 'molida', 'Carne molida');
    await tester.enterText(campo('Cantidad'), '10');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Añadir'));
    await tester.pumpAndSettle();

    await elegir(tester, 'queso', 'Queso blanco duro');
    await tester.enterText(campo('Marca'), 'Marca A');
    await tester.enterText(campo('Piezas'), '6');
    await tester.enterText(campo('Peso'), '4,9');
    await tester.enterText(campo('Costo /kg'), '4,10');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Añadir'));
    await tester.pumpAndSettle();
    expect(find.text('2 productos · Total'), findsOneWidget);
    expect(find.text(r'$ 65,09'), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(compras.compras.single.lineas, hasLength(2));
    expect(compras.deudaDe('Frigorífico 1'), 6509);
    final queso = existencias.productos.firstWhere((p) => p.id == 'q');
    expect(queso.lotes.single.proveedor, 'Frigorífico 1');
    expect(queso.lotes.single.piezas, 6);
  });

  testWidgets('cash with Alt+Q leaves nothing owed', (tester) async {
    await abrir(tester);
    await elegir(tester, 'molida', 'Carne molida');
    await tester.enterText(campo('Cantidad'), '2');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Añadir'));
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyQ);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar pedido'));
    await tester.pumpAndSettle();
    expect(compras.compras.single.aCredito, isFalse);
    expect(compras.deudaDe('Frigorífico 1'), 0);
  });

  testWidgets('an empty invoice is not registered', (tester) async {
    await abrir(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar pedido'));
    await tester.pumpAndSettle();
    expect(
      find.text('Añade al menos un producto (Enter en el costo)'),
      findsOneWidget,
    );
    expect(compras.compras, isEmpty);
  });
}
