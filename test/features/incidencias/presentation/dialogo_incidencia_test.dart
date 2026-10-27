import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/data/repositorio_incidencias_en_memoria.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/incidencias/presentation/dialogo_incidencia.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  late ControladorExistencias existencias;
  late ControladorIncidencias incidencias;

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
          nombre: 'Suero',
          categoria: Categoria.quesos,
          forma: FormaConteo.porLitro,
          minimo: 2000,
          lotes: [
            LoteMarca(
              marca: 'Marca C',
              proveedor: 'Distribuidora 1',
              cantidad: 12000,
            ),
          ],
        ),
      ]),
    );
    await existencias.cargar();
    incidencias = ControladorIncidencias(
      RepositorioIncidenciasEnMemoria(),
      existencias,
    );
    await incidencias.cargar();
  });

  tearDown(() {
    incidencias.dispose();
    existencias.dispose();
  });

  Future<void> abrir(WidgetTester tester, {String proveedor = ''}) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => unawaited(
                mostrarDialogoIncidencia(
                  context,
                  incidencias: incidencias,
                  existencias: existencias,
                  proveedores: const ['Distribuidora 1', 'Distribuidora 2'],
                  proveedorInicial: proveedor,
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

  LoteMarca lote(String marca) => existencias.productos
      .expand((p) => p.lotes)
      .firstWhere((l) => l.marca == marca);

  Future<void> conAlt(WidgetTester tester, LogicalKeyboardKey tecla) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(tecla);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
  }

  Future<void> registrar(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar incidencia'));
    await tester.pumpAndSettle();
  }

  testWidgets('offers only what that supplier brings', (tester) async {
    await abrir(tester, proveedor: 'Distribuidora 1');
    expect(find.text('Queso blanco duro'), findsOneWidget);
    expect(find.text('Suero'), findsOneWidget);
    expect(find.textContaining('Marca B'), findsNothing);
  });

  testWidgets('takes damaged pieces out of that brand and shows it', (
    tester,
  ) async {
    await abrir(tester, proveedor: 'Distribuidora 1');
    await conAlt(tester, LogicalKeyboardKey.digit1);
    await tester.enterText(campo('Piezas afectadas'), '2');
    await tester.enterText(campo('Peso'), '1,6');
    await tester.pump();
    expect(find.text('Marca A quedará en 8 piezas · 6,6 kg'), findsOneWidget);
    await registrar(tester);

    expect(find.byType(Dialog), findsNothing);
    expect(lote('Marca A').piezas, 8);
    expect(lote('Marca A').cantidad, 6600);
    expect(lote('Marca B').piezas, 14);
    final incidencia = incidencias.todas.single;
    expect(incidencia.tipo, TipoIncidencia.malEstado);
    expect(incidencia.proveedor, 'Distribuidora 1');
    expect(find.textContaining('Incidencia registrada'), findsOneWidget);
  });

  testWidgets('a missing weight leaves the stock alone by default', (
    tester,
  ) async {
    await abrir(tester, proveedor: 'Distribuidora 1');
    await conAlt(tester, LogicalKeyboardKey.digit2);
    await conAlt(tester, LogicalKeyboardKey.keyE);
    expect(find.text('El inventario no cambia'), findsOneWidget);
    await tester.enterText(campo('Cantidad'), '0,5');
    await registrar(tester);

    expect(lote('Marca C').cantidad, 12000);
    expect(incidencias.todas.single.tipo, TipoIncidencia.faltante);
    expect(incidencias.todas.single.sacada, isFalse);
  });

  testWidgets('will not take out more than the brand holds', (tester) async {
    await abrir(tester, proveedor: 'Distribuidora 1');
    await conAlt(tester, LogicalKeyboardKey.digit1);
    await tester.enterText(campo('Piezas afectadas'), '12');
    await tester.enterText(campo('Peso'), '1');
    await registrar(tester);

    expect(find.text('Solo hay 10'), findsOneWidget);
    expect(incidencias.todas, isEmpty);
  });

  testWidgets('asks for the product before registering', (tester) async {
    await abrir(tester, proveedor: 'Distribuidora 1');
    await registrar(tester);
    expect(find.text('Elige el producto (Alt+1…)'), findsOneWidget);
    expect(incidencias.todas, isEmpty);
  });

  testWidgets('typing the supplier shows its products', (tester) async {
    await abrir(tester);
    expect(find.text('Queso blanco duro'), findsNothing);
    await tester.enterText(campo('Proveedor'), 'Distribuidora 2');
    await tester.pumpAndSettle();
    expect(find.text('Queso blanco duro'), findsOneWidget);
    expect(find.text('Suero'), findsNothing);
  });

  testWidgets('Ctrl+S registers', (tester) async {
    await abrir(tester, proveedor: 'Distribuidora 1');
    await conAlt(tester, LogicalKeyboardKey.digit2);
    await tester.enterText(campo('Cantidad'), '2');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(lote('Marca C').cantidad, 10000);
  });
}
