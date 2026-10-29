import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/data/almacen_imagenes_en_memoria.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/dialogo_nuevo_producto.dart';

void main() {
  late ControladorExistencias controlador;
  late GestorFotos fotos;
  Uint8List? imagenElegida;

  setUp(() async {
    fotos = GestorFotos(AlmacenImagenesEnMemoria());
    imagenElegida = null;
    controlador = ControladorExistencias(
      RepositorioProductosEnMemoria(const [
        Producto(
          id: 'p1',
          nombre: 'Jamón de pierna',
          categoria: Categoria.embutidos,
          forma: FormaConteo.piezasYKilos,
          minimo: 4,
        ),
      ]),
    );
    await controlador.cargar();
  });

  tearDown(() => controlador.dispose());

  Future<void> abrir(
    WidgetTester tester, {
    List<String> proveedores = const [],
  }) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => unawaited(
                mostrarDialogoNuevoProducto(
                  context,
                  controlador,
                  fotos: fotos,
                  proveedores: proveedores,
                  aBolivares: (dolares) => dolares * 40,
                  elegirImagen: () async => imagenElegida,
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

  Producto? creado(String nombre) {
    for (final producto in controlador.visibles) {
      if (producto.nombre == nombre) return producto;
    }
    return null;
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

  // Types into whichever field has the focus, then presses Enter there.
  Future<void> escribirYEnter(WidgetTester tester, String texto) async {
    tester.testTextInput.enterText(texto);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();
  }

  Future<void> crear(WidgetTester tester) async {
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Crear'));
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();
  }

  testWidgets('creates a cheese in pieces and kilos with two brands', (
    tester,
  ) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre'), 'Queso de año');
    await conTecla(
      tester,
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.digit4,
    );
    await conTecla(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.keyQ);
    await tester.enterText(campo('Marca'), 'Marca A');
    await tester.enterText(campo('Proveedor'), 'Distribuidora 1');
    await tester.enterText(campo('Piezas'), '10');
    await tester.enterText(campo('Peso'), '8,2');
    await conTecla(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyM,
    );
    await tester.enterText(campo('Marca').last, 'Marca B');
    await tester.enterText(campo('Piezas').last, '15');
    await tester.enterText(campo('Peso').last, '11,8');
    await tester.pump();
    expect(
      find.text('Total: 25 piezas · 20 kg · ≈ 0,8 kg por pieza'),
      findsOneWidget,
    );
    await tester.enterText(campo('Avisar cuando queden (total)'), '5');
    await crear(tester);

    final producto = creado('Queso de año');
    expect(producto?.categoria, Categoria.quesos);
    expect(producto?.forma, FormaConteo.piezasYKilos);
    expect(producto?.minimo, 5);
    expect(producto?.lotes, const [
      LoteMarca(
        marca: 'Marca A',
        proveedor: 'Distribuidora 1',
        piezas: 10,
        cantidad: 8200,
      ),
      LoteMarca(marca: 'Marca B', piezas: 15, cantidad: 11800),
    ]);
    expect(find.byType(DialogoNuevoProducto), findsNothing);
    expect(find.text('Producto creado · Queso de año'), findsOneWidget);
  });

  testWidgets('Enter walks the fields and creates on the last one', (
    tester,
  ) async {
    await abrir(tester);
    await escribirYEnter(tester, 'Carne molida');
    await escribirYEnter(tester, 'Propia');
    await escribirYEnter(tester, 'Frigorífico 1');
    await escribirYEnter(tester, '3,8');
    await escribirYEnter(tester, '4,10');
    await escribirYEnter(tester, '6,20');
    await escribirYEnter(tester, '8');

    final producto = creado('Carne molida');
    expect(producto?.forma, FormaConteo.porKilo);
    expect(producto?.cantidad, 3800);
    expect(producto?.lotes.single.costo, 410);
    expect(producto?.lotes.single.precio, 620);
    expect(producto?.minimo, 8000);
  });

  testWidgets('each brand keeps its own price, shown in bolívares too', (
    tester,
  ) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre'), 'Queso de año');
    await tester.enterText(campo('Marca'), 'Marca A');
    await tester.enterText(campo('Cantidad'), '8,2');
    await tester.enterText(campo('Precio'), '5,20');
    await tester.pump();
    expect(find.text('= 208,00 Bs'), findsOneWidget);
    await conTecla(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyM,
    );
    // The new row may land below the fold of the window.
    for (final (etiqueta, texto) in [
      ('Marca', 'Marca B'),
      ('Cantidad', '11'),
      ('Precio', '5,60'),
    ]) {
      await tester.ensureVisible(campo(etiqueta).last);
      await tester.pumpAndSettle();
      await tester.enterText(campo(etiqueta).last, texto);
    }
    await crear(tester);

    expect(creado('Queso de año')?.lotes.map((l) => l.precio), [520, 560]);
  });

  testWidgets('Alt+F adds a photo that is saved with the product', (
    tester,
  ) async {
    imagenElegida = Uint8List.fromList([1, 2, 3]);
    await abrir(tester);
    await tester.enterText(campo('Nombre'), 'Mortadela');
    await conTecla(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.keyF);
    expect(find.text('Cambiar foto'), findsOneWidget);
    await crear(tester);
    expect(creado('Mortadela')?.imagenId, isNotNull);
  });

  testWidgets('a file that is not an image is rejected with a hint', (
    tester,
  ) async {
    imagenElegida = Uint8List(0);
    await abrir(tester);
    await tester.tap(find.text('Elegir foto'));
    await tester.pumpAndSettle();
    expect(
      find.text('Ese archivo no es una imagen. Usa una foto JPG, PNG o WebP.'),
      findsOneWidget,
    );
  });

  testWidgets('Alt+number picks the category while typing the name', (
    tester,
  ) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre'), 'Pollo');
    await conTecla(
      tester,
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.digit2,
    );
    await crear(tester);
    expect(creado('Pollo')?.categoria, Categoria.aves);
  });

  testWidgets('creates a product without stock when no brand is given', (
    tester,
  ) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre'), 'Mortadela');
    await crear(tester);
    final producto = creado('Mortadela');
    expect(producto?.lotes, isEmpty);
    expect(producto?.minimo, 0);
  });

  testWidgets('a brand row needs its brand and quantities', (tester) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre'), 'Queso paisa');
    await conTecla(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.keyQ);
    await tester.enterText(campo('Piezas'), '4');
    await crear(tester);
    expect(find.text('Falta la marca'), findsOneWidget);
    expect(find.text('Falta'), findsOneWidget);
    expect(creado('Queso paisa'), isNull);
  });

  testWidgets('the same brand and supplier cannot appear twice', (
    tester,
  ) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre'), 'Chorizo');
    await tester.enterText(campo('Marca'), 'Marca X');
    await tester.enterText(campo('Cantidad'), '2');
    await conTecla(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyM,
    );
    await tester.enterText(campo('Marca').last, 'marca x');
    await tester.enterText(campo('Cantidad').last, '1');
    await crear(tester);
    expect(find.text('Ya está arriba'), findsOneWidget);
    expect(creado('Chorizo'), isNull);
  });

  testWidgets('warns about a repeated name and stays open', (tester) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre'), 'jamon de pierna');
    await crear(tester);
    expect(find.text('Ya existe un producto con ese nombre'), findsOneWidget);

    await tester.enterText(campo('Nombre'), 'Jamón cocido');
    await tester.pump();
    expect(find.text('Ya existe un producto con ese nombre'), findsNothing);
  });

  testWidgets('rejects decimals for products sold by unit', (tester) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre'), 'Salchicha');
    await conTecla(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.keyR);
    await tester.enterText(campo('Marca'), 'Marca D');
    await tester.enterText(campo('Cantidad'), '2,5');
    await crear(tester);
    expect(find.text('Solo enteros'), findsOneWidget);
    expect(creado('Salchicha'), isNull);
  });

  testWidgets('Ctrl+Enter creates and leaves a clean form for another', (
    tester,
  ) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre'), 'Queso paisa');
    await conTecla(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyM,
    );
    await conTecla(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.enter,
    );

    expect(creado('Queso paisa'), isNotNull);
    expect(find.byType(DialogoNuevoProducto), findsOneWidget);
    expect(campo('Marca'), findsOneWidget);
    final nombre = tester.widget<TextFormField>(campo('Nombre'));
    expect(nombre.controller?.text, isEmpty);
  });

  testWidgets('Esc closes without creating', (tester) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre'), 'Chorizo');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoNuevoProducto), findsNothing);
    expect(creado('Chorizo'), isNull);
  });

  // A mouse click on a category or counting option leaves no field focused.
  testWidgets('shortcuts still work when no field has the focus', (
    tester,
  ) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre'), 'Queso de mano');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    await conTecla(
      tester,
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.digit4,
    );
    await conTecla(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.keyQ);
    await conTecla(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyM,
    );
    expect(campo('Marca'), findsNWidgets(2));

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await conTecla(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.enter,
    );
    final producto = creado('Queso de mano');
    expect(producto?.categoria, Categoria.quesos);
    expect(producto?.forma, FormaConteo.piezasYKilos);
  });

  group('supplier suggestions', () {
    const guardados = ['Distribuidora 1', 'Distribuidora 2', 'Avícola 1'];

    testWidgets('suggest saved suppliers while typing', (tester) async {
      await abrir(tester, proveedores: guardados);
      await tester.enterText(campo('Proveedor'), 'distrib');
      await tester.pump();
      expect(find.widgetWithText(ListTile, 'Distribuidora 1'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Distribuidora 2'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Avícola 1'), findsNothing);
    });

    testWidgets('an empty field lists every saved supplier to pick one', (
      tester,
    ) async {
      await abrir(tester, proveedores: guardados);
      await tester.tap(find.byTooltip('Ver proveedores'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));
      await tester.tap(find.widgetWithText(ListTile, 'Distribuidora 2'));
      await tester.pump();
      final proveedor = tester.widget<TextFormField>(campo('Proveedor'));
      expect(proveedor.controller?.text, 'Distribuidora 2');
    });

    testWidgets('a click fills in the exact saved name', (tester) async {
      await abrir(tester, proveedores: guardados);
      await tester.enterText(campo('Proveedor'), 'avicola');
      await tester.pump();
      await tester.tap(find.widgetWithText(ListTile, 'Avícola 1'));
      await tester.pump();
      final proveedor = tester.widget<TextFormField>(campo('Proveedor'));
      expect(proveedor.controller?.text, 'Avícola 1');
    });

    testWidgets('Enter takes the first suggestion', (tester) async {
      await abrir(tester, proveedores: guardados);
      await tester.tap(campo('Proveedor'));
      tester.testTextInput.enterText('dist');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      final proveedor = tester.widget<TextFormField>(campo('Proveedor'));
      expect(proveedor.controller?.text, 'Distribuidora 1');
    });

    testWidgets('a supplier not saved yet is still accepted', (tester) async {
      await abrir(tester, proveedores: guardados);
      await tester.enterText(campo('Nombre'), 'Queso paisa');
      await tester.enterText(campo('Marca'), 'Marca Z');
      await tester.enterText(campo('Proveedor'), 'Lácteos Nuevo');
      await tester.enterText(campo('Cantidad'), '3');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Crear'));
      await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
      await tester.pumpAndSettle();
      expect(creado('Queso paisa')?.lotes.single.proveedor, 'Lácteos Nuevo');
    });
  });
}
