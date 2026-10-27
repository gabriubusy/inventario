import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/data/almacen_imagenes_en_memoria.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/dialogo_nuevo_producto.dart';
import 'package:inventario/features/productos/presentation/pantalla_productos.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/data/almacen_tasa_en_memoria.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';

void main() {
  final hoy = DateTime(2026, 10, 25, 10);
  late ControladorExistencias existencias;
  late ControladorListaProductos lista;
  late ControladorTasa tasa;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const [
        Producto(
          id: 'p1',
          nombre: 'Jamón de pierna',
          categoria: Categoria.embutidos,
          forma: FormaConteo.piezasYKilos,
          minimo: 4,
          lotes: [
            LoteMarca(
              marca: 'Marca F',
              proveedor: 'Distribuidora 1',
              piezas: 3,
              piezaAbierta: true,
              cantidad: 16400,
              precio: 980,
            ),
          ],
        ),
        Producto(
          id: 'p2',
          nombre: 'Queso guayanés',
          categoria: Categoria.quesos,
          forma: FormaConteo.piezasYKilos,
          minimo: 3,
        ),
      ]),
    );
    await existencias.cargar();
    lista = ControladorListaProductos(existencias);
    tasa = ControladorTasa(
      AlmacenTasaEnMemoria(TasaCambio(bolivaresPorDolar: 4000, fecha: hoy)),
      ahora: () => hoy,
    );
    await tasa.cargar();
  });

  tearDown(() {
    lista.dispose();
    tasa.dispose();
    existencias.dispose();
  });

  Producto guardado(String id) =>
      existencias.productos.firstWhere((p) => p.id == id);

  Finder campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

  Future<void> abrir(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => unawaited(
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PantallaProductos(
                      lista: lista,
                      tasa: tasa,
                      fotos: GestorFotos(AlmacenImagenesEnMemoria()),
                    ),
                  ),
                ),
              ),
              child: const Text('inicio'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('inicio'));
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

  Future<void> tecla(WidgetTester tester, LogicalKeyboardKey tecla) async {
    await tester.sendKeyEvent(tecla);
    await tester.pumpAndSettle();
  }

  testWidgets('lists each product with its price in dollars and bolívares', (
    tester,
  ) async {
    await abrir(tester);
    expect(find.text(r'$ 9,80 /kg'), findsOneWidget);
    expect(find.text('392,00 Bs'), findsOneWidget);
    expect(find.text('Sin precio'), findsOneWidget);
    expect(find.text('1 \$ = 40,00 Bs'), findsOneWidget);
  });

  testWidgets('arrows choose and Enter opens the edit window', (tester) async {
    await abrir(tester);
    // Sold out first, so the cheese starts chosen.
    await tecla(tester, LogicalKeyboardKey.arrowDown);
    await tecla(tester, LogicalKeyboardKey.enter);
    expect(find.text('Editar producto'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Jamón de pierna'),
      findsOneWidget,
    );
  });

  testWidgets('clicking a product opens its edit window', (tester) async {
    await abrir(tester);
    await tester.tap(find.text('Jamón de pierna'));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoNuevoProducto), findsOneWidget);
    expect(find.text('Editar producto'), findsOneWidget);
  });

  testWidgets('Ctrl+S saves the edit and Deshacer brings it back', (
    tester,
  ) async {
    await abrir(tester);
    await tecla(tester, LogicalKeyboardKey.arrowDown);
    await tecla(tester, LogicalKeyboardKey.enter);
    await tester.enterText(campo('Avisar cuando queden (total)'), '6');
    await tester.enterText(campo('Precio'), '10,50');
    await conTecla(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyS,
    );
    expect(guardado('p1').minimo, 6);
    expect(guardado('p1').lotes.single.precio, 1050);
    // The stock is untouched by an edit.
    expect(guardado('p1').lotes.single.piezaAbierta, isTrue);
    expect(guardado('p1').cantidad, 16400);
    expect(find.byType(DialogoNuevoProducto), findsNothing);
    expect(find.text('Jamón de pierna guardado'), findsOneWidget);

    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();
    expect(guardado('p1').minimo, 4);
    expect(guardado('p1').lotes.single.precio, 980);
  });

  testWidgets('the way of counting is locked while there is stock', (
    tester,
  ) async {
    await abrir(tester);
    await tecla(tester, LogicalKeyboardKey.enter);
    expect(find.text('Por litro'), findsOneWidget);
    await tecla(tester, LogicalKeyboardKey.escape);
    await tecla(tester, LogicalKeyboardKey.arrowDown);
    await tecla(tester, LogicalKeyboardKey.enter);
    expect(find.text('No se cambia mientras haya existencias'), findsOneWidget);
    expect(find.text('Por litro'), findsNothing);
  });

  testWidgets('Ctrl+T sets today\'s rate and prices follow it', (tester) async {
    tasa = ControladorTasa(AlmacenTasaEnMemoria(), ahora: () => hoy);
    await abrir(tester);
    expect(
      find.text('Pon la tasa de hoy para ver los precios en bolívares.'),
      findsOneWidget,
    );
    await conTecla(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyT,
    );
    await tester.enterText(campo('Bolívares por 1 dólar'), '41');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('401,80 Bs'), findsOneWidget);
    expect(
      find.text('Pon la tasa de hoy para ver los precios en bolívares.'),
      findsNothing,
    );
  });

  testWidgets('a search with no results offers to create that product', (
    tester,
  ) async {
    await abrir(tester);
    await tester.enterText(find.byType(TextField).first, 'chorizo');
    await tester.pumpAndSettle();
    expect(find.text('No hay productos con “chorizo”'), findsOneWidget);
    await tester.tap(find.text('Crear “Chorizo”'));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoNuevoProducto), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Chorizo'), findsOneWidget);
  });

  testWidgets('Esc clears the search first and then goes home', (tester) async {
    await abrir(tester);
    await tester.enterText(find.byType(TextField).first, 'jam');
    await tester.pumpAndSettle();
    await tecla(tester, LogicalKeyboardKey.escape);
    expect(lista.busqueda, isEmpty);
    expect(find.byType(PantallaProductos), findsOneWidget);
    await tecla(tester, LogicalKeyboardKey.escape);
    expect(find.byType(PantallaProductos), findsNothing);
  });

  testWidgets('Ctrl+N opens the new product window', (tester) async {
    await abrir(tester);
    await conTecla(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyN,
    );
    expect(find.byType(DialogoNuevoProducto), findsOneWidget);
  });
}
