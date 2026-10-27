import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/ajustes/application/controlador_ajustes.dart';
import 'package:inventario/features/ajustes/presentation/dialogo_ajuste.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  late ControladorExistencias existencias;
  late ControladorMovimientos movimientos;
  late ControladorAjustes ajustes;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const [
        Producto(
          id: 'p1',
          nombre: 'Carne molida',
          categoria: Categoria.carnes,
          forma: FormaConteo.porKilo,
          minimo: 8000,
          lotes: [
            LoteMarca(
              marca: 'Propia',
              proveedor: 'Frigorífico 1',
              cantidad: 3800,
            ),
          ],
        ),
      ]),
    );
    await existencias.cargar();
    movimientos = ControladorMovimientos(RepositorioMovimientosEnMemoria());
    ajustes = ControladorAjustes(existencias, movimientos: movimientos);
  });

  tearDown(() {
    ajustes.dispose();
    movimientos.dispose();
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
                mostrarDialogoAjuste(
                  context,
                  ajustes: ajustes,
                  existencias: existencias,
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
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Producto'),
      'molida',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, 'Carne molida'));
    await tester.pumpAndSettle();
  }

  Finder campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

  testWidgets('a merma shows what is left and takes it out', (tester) async {
    await abrir(tester);
    await tester.enterText(campo('Cantidad'), '0,4');
    await tester.pump();
    expect(find.text('Propia quedará: 3,8 kg → 3,4 kg'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar merma'));
    await tester.pumpAndSettle();
    expect(existencias.productos.single.cantidad, 3400);
    expect(movimientos.todos.single.nota, 'Recorte');
    expect(find.textContaining('Merma registrada'), findsOneWidget);
  });

  testWidgets('Alt+W switches to theft and Alt+S picks its reason', (
    tester,
  ) async {
    await abrir(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyW);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    await tester.enterText(campo('Cantidad'), '1');
    await tester.tap(
      find.widgetWithText(FilledButton, 'Registrar robo o pérdida'),
    );
    await tester.pumpAndSettle();
    final anotado = movimientos.todos.single;
    expect(anotado.tipo, TipoMovimiento.robo);
    expect(anotado.nota, 'Faltante sin explicar');
  });

  testWidgets('more than there is shows the limit', (tester) async {
    await abrir(tester);
    await tester.enterText(campo('Cantidad'), '5');
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar merma'));
    await tester.pumpAndSettle();
    expect(find.text('Solo hay 3,8'), findsOneWidget);
    expect(movimientos.todos, isEmpty);
  });
}
