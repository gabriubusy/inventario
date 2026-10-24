import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/inicio/presentation/pantalla_inicio.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/tarjeta_producto.dart';

void main() {
  late ControladorExistencias controlador;
  var bloqueos = 0;

  setUp(() async {
    controlador = ControladorExistencias(
      const RepositorioProductosEnMemoria([
        Producto(
          id: '1',
          nombre: 'Bistec de res',
          categoria: Categoria.carnes,
          unidad: UnidadBase.kg,
          existencia: 18500,
          minimo: 8000,
        ),
        Producto(
          id: '2',
          nombre: 'Jamón de pierna',
          categoria: Categoria.embutidos,
          unidad: UnidadBase.kg,
          existencia: 1200,
          minimo: 5000,
        ),
        Producto(
          id: '3',
          nombre: 'Queso guayanés',
          categoria: Categoria.quesos,
          unidad: UnidadBase.kg,
          existencia: 0,
          minimo: 4000,
        ),
      ]),
    );
    await controlador.cargar();
    bloqueos = 0;
  });

  tearDown(() => controlador.dispose());

  Future<void> mostrar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaInicio(
          controlador: controlador,
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
}
