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
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/data/repositorio_proveedores_en_memoria.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/presentation/dialogo_proveedor.dart';
import 'package:inventario/features/proveedores/presentation/ficha_proveedor.dart';
import 'package:inventario/features/proveedores/presentation/pantalla_proveedores.dart';

void main() {
  late ControladorExistencias existencias;
  late ControladorProveedores controlador;

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
          ],
        ),
      ]),
    );
    await existencias.cargar();
    controlador = ControladorProveedores(
      RepositorioProveedoresEnMemoria(const [
        Proveedor(id: 'v1', nombre: 'Avícola 1', telefono: '0412-000.00.00'),
        Proveedor(
          id: 'v2',
          nombre: 'Distribuidora 1',
          rif: 'J-00000000-0',
          notas: 'Pasa lunes y jueves',
        ),
      ]),
      existencias,
    );
    await controlador.cargar();
  });

  tearDown(() {
    controlador.dispose();
    existencias.dispose();
  });

  Future<void> mostrar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaProveedores(
          controlador: controlador,
          existencias: existencias,
          entradas: ControladorEntradas(existencias),
        ),
      ),
    );
  }

  Finder enFicha(String texto) => find.descendant(
    of: find.byType(FichaProveedor),
    matching: find.text(texto),
  );

  Future<void> conControl(WidgetTester tester, LogicalKeyboardKey tecla) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(tecla);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
  }

  testWidgets('shows the first supplier, which brings nothing yet', (
    tester,
  ) async {
    await mostrar(tester);
    expect(enFicha('Avícola 1'), findsOneWidget);
    expect(enFicha('0412-000.00.00'), findsOneWidget);
    expect(
      enFicha(
        'Aparecen al crear productos o registrar entradas con este proveedor.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the down arrow shows the next supplier and what it brings', (
    tester,
  ) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(enFicha('Distribuidora 1'), findsOneWidget);
    expect(enFicha('RIF J-00000000-0'), findsOneWidget);
    expect(enFicha('Marca A'), findsNWidgets(2));
    expect(enFicha('Queso blanco duro'), findsOneWidget);
    expect(enFicha('10 piezas · 8,2 kg'), findsOneWidget);
  });

  testWidgets('clicking a supplier shows its card', (tester) async {
    await mostrar(tester);
    await tester.tap(find.text('Distribuidora 1'));
    await tester.pump();
    expect(enFicha('Pasa lunes y jueves'), findsOneWidget);
  });

  testWidgets('searching by brand narrows the list', (tester) async {
    await mostrar(tester);
    await tester.enterText(find.byType(TextField), 'marca a');
    await tester.pump();
    expect(find.text('Avícola 1'), findsNothing);
    expect(enFicha('Distribuidora 1'), findsOneWidget);
  });

  testWidgets('Ctrl+N creates a supplier and selects it', (tester) async {
    await mostrar(tester);
    await conControl(tester, LogicalKeyboardKey.keyN);
    expect(find.byType(DialogoProveedor), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Lácteos 1',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoProveedor), findsNothing);
    expect(enFicha('Lácteos 1'), findsOneWidget);
    expect(find.text('Proveedor creado · Lácteos 1'), findsOneWidget);
  });

  testWidgets('a repeated supplier name keeps the window open', (tester) async {
    await mostrar(tester);
    await conControl(tester, LogicalKeyboardKey.keyN);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'avicola 1',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();
    expect(find.text('Ya existe un proveedor con ese nombre'), findsOneWidget);
  });

  testWidgets('Ctrl+E edits the chosen supplier', (tester) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await conControl(tester, LogicalKeyboardKey.keyE);
    expect(find.text('Editar proveedor'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Distribuidora Uno',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();
    expect(enFicha('Distribuidora Uno'), findsOneWidget);
    expect(enFicha('Queso blanco duro'), findsOneWidget);
  });

  testWidgets('F2 opens an entry with the chosen supplier preselected', (
    tester,
  ) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoEntrada), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Producto'),
      'queso',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, 'Queso blanco duro'));
    await tester.pumpAndSettle();
    final elegida = tester.widget<OpcionSeleccionable>(
      find.widgetWithText(OpcionSeleccionable, 'Marca A'),
    );
    expect(elegida.elegida, isTrue);
  });
}
