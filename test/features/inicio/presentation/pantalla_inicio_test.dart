import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/inicio/presentation/pantalla_inicio.dart';
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
import 'package:inventario/features/productos/presentation/tarjeta_producto.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/data/repositorio_proveedores_en_memoria.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/presentation/pantalla_proveedores.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/data/almacen_tasa_en_memoria.dart';

void main() {
  late ControladorExistencias controlador;
  late ControladorProveedores proveedores;
  var bloqueos = 0;

  setUp(() async {
    controlador = ControladorExistencias(
      RepositorioProductosEnMemoria([
        const Producto(
          id: '1',
          nombre: 'Bistec de res',
          categoria: Categoria.carnes,
          forma: FormaConteo.porKilo,
          minimo: 8000,
          lotes: [LoteMarca(marca: 'Propia', cantidad: 18500)],
        ),
        const Producto(
          id: '2',
          nombre: 'Jamón de pierna',
          categoria: Categoria.embutidos,
          forma: FormaConteo.piezasYKilos,
          minimo: 5,
          lotes: [
            LoteMarca(
              marca: 'Marca F',
              piezas: 3,
              piezaAbierta: true,
              cantidad: 16400,
            ),
          ],
        ),
        const Producto(
          id: '3',
          nombre: 'Queso guayanés',
          categoria: Categoria.quesos,
          forma: FormaConteo.piezasYKilos,
          minimo: 3,
        ),
      ]),
    );
    await controlador.cargar();
    proveedores = ControladorProveedores(
      RepositorioProveedoresEnMemoria(const [
        Proveedor(id: 'v1', nombre: 'Distribuidora 1'),
      ]),
      controlador,
    );
    await proveedores.cargar();
    bloqueos = 0;
  });

  tearDown(() {
    controlador.dispose();
    proveedores.dispose();
  });

  Future<void> mostrar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaInicio(
          controlador: controlador,
          proveedores: proveedores,
          entradas: ControladorEntradas(controlador),
          listaProductos: ControladorListaProductos(controlador),
          tasa: ControladorTasa(AlmacenTasaEnMemoria()),
          fotos: GestorFotos(AlmacenImagenesEnMemoria()),
          onBloquear: () => bloqueos++,
        ),
      ),
    );
  }

  Future<void> pulsarConControl(
    WidgetTester tester,
    LogicalKeyboardKey tecla,
  ) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(tecla);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
  }

  testWidgets('shows pieces, the open piece and the brands of a cheese', (
    tester,
  ) async {
    await mostrar(tester);
    expect(find.text('3 piezas'), findsOneWidget);
    expect(find.text('+1 abierta'), findsOneWidget);
    expect(find.text('Marca F: 3 + 1 abierta'), findsOneWidget);
  });

  testWidgets('lists every product with its stock and alert', (tester) async {
    await mostrar(tester);
    expect(find.byType(TarjetaProducto), findsNWidgets(3));
    expect(find.text('18,5 kg'), findsOneWidget);
    expect(find.text('Stock bajo'), findsOneWidget);
    expect(find.text('Agotado'), findsOneWidget);
  });

  testWidgets('search narrows the list ignoring accents', (tester) async {
    await mostrar(tester);
    await tester.enterText(find.byType(TextField), 'jamon');
    await tester.pump();
    expect(find.byType(TarjetaProducto), findsOneWidget);
    expect(find.text('Jamón de pierna'), findsOneWidget);
  });

  testWidgets('Esc clears the search', (tester) async {
    await mostrar(tester);
    await tester.enterText(find.byType(TextField), 'jamon');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.byType(TarjetaProducto), findsNWidgets(3));
  });

  testWidgets('says so when nothing matches', (tester) async {
    await mostrar(tester);
    await tester.enterText(find.byType(TextField), 'pescado');
    await tester.pump();
    expect(find.text('No hay productos que coincidan'), findsOneWidget);
  });

  testWidgets('a category chip filters the list', (tester) async {
    await mostrar(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Quesos'));
    await tester.pump();
    expect(find.byType(TarjetaProducto), findsOneWidget);
    expect(find.text('Queso guayanés'), findsOneWidget);
  });

  testWidgets('Ctrl+K moves the focus to the search box', (tester) async {
    await mostrar(tester);
    await pulsarConControl(tester, LogicalKeyboardKey.keyK);
    final campo = tester.widget<TextField>(find.byType(TextField));
    expect(campo.focusNode?.hasFocus, isTrue);
  });

  testWidgets('F1 triggers the sale action', (tester) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pump();
    expect(find.text('Próximamente: Registrar salida'), findsOneWidget);
  });

  testWidgets('Ctrl+L locks the session', (tester) async {
    await mostrar(tester);
    await pulsarConControl(tester, LogicalKeyboardKey.keyL);
    expect(bloqueos, 1);
  });

  testWidgets('F5 opens the suppliers and Esc comes back', (tester) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f5);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaProveedores), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaProveedores), findsNothing);
    expect(find.text('Existencias'), findsOneWidget);
  });

  testWidgets('F4 opens the products and Esc comes back', (tester) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f4);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaProductos), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaProductos), findsNothing);
  });

  testWidgets('Ctrl+N opens the new product window', (tester) async {
    await mostrar(tester);
    await pulsarConControl(tester, LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoNuevoProducto), findsOneWidget);
  });

  testWidgets('home shortcuts stay quiet while the window is open', (
    tester,
  ) async {
    await mostrar(tester);
    await pulsarConControl(tester, LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    await pulsarConControl(tester, LogicalKeyboardKey.keyN);
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoNuevoProducto), findsOneWidget);
    expect(find.text('Próximamente: Registrar salida'), findsNothing);
  });

  testWidgets('home shortcuts work while typing in the search box', (
    tester,
  ) async {
    await mostrar(tester);
    await tester.enterText(find.byType(TextField), 'jam');
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pump();
    expect(find.text('Próximamente: Registrar salida'), findsOneWidget);
  });

  testWidgets('a product created from home appears in the grid', (
    tester,
  ) async {
    await mostrar(tester);
    await tester.tap(find.text('Nuevo producto'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Queso de año',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();
    expect(find.byType(TarjetaProducto), findsNWidgets(4));
    expect(find.text('Queso de año'), findsOneWidget);
  });
}
