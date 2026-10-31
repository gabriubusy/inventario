import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/conteo/application/controlador_conteo.dart';
import 'package:inventario/features/conteo/presentation/fila_conteo.dart';
import 'package:inventario/features/conteo/presentation/pantalla_conteo.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  late ControladorExistencias existencias;
  late ControladorMovimientos movimientos;
  late ControladorConteo conteo;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const [
        Producto(
          id: 'm',
          nombre: 'Carne molida',
          categoria: Categoria.carnes,
          forma: FormaConteo.porKilo,
          minimo: 8000,
          lotes: [LoteMarca(marca: 'Propia', cantidad: 3800)],
        ),
        Producto(
          id: 'q',
          nombre: 'Queso blanco duro',
          categoria: Categoria.quesos,
          forma: FormaConteo.piezasYKilos,
          minimo: 5,
          lotes: [LoteMarca(marca: 'Marca A', piezas: 10, cantidad: 8200)],
        ),
      ]),
    );
    await existencias.cargar();
    movimientos = ControladorMovimientos(RepositorioMovimientosEnMemoria());
    conteo = ControladorConteo(existencias, movimientos: movimientos);
  });

  tearDown(() {
    conteo.dispose();
    movimientos.dispose();
    existencias.dispose();
  });

  Future<void> mostrar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaConteo(conteo: conteo, existencias: existencias),
      ),
    );
  }

  Finder campoDe(String producto, String etiqueta) => find.descendant(
    of: find.widgetWithText(FilaConteo, producto),
    matching: find.widgetWithText(TextField, etiqueta),
  );

  testWidgets('typing a count shows the difference', (tester) async {
    await mostrar(tester);
    await tester.enterText(campoDe('Carne molida', 'Contado'), '3,4');
    await tester.pump();
    expect(find.text('−0,4 kg'), findsOneWidget);
    expect(find.text('Guardar 1 ajuste'), findsOneWidget);
  });

  testWidgets('Ctrl+S saves every difference at once', (tester) async {
    await mostrar(tester);
    await tester.enterText(campoDe('Carne molida', 'Contado'), '3,4');
    await tester.enterText(campoDe('Queso blanco duro', 'Piezas'), '9');
    await tester.enterText(campoDe('Queso blanco duro', 'Peso'), '7,5');
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    final queso = existencias.productos.firstWhere((p) => p.id == 'q');
    expect(queso.lotes.single.piezas, 9);
    expect(queso.cantidad, 7500);
    expect(movimientos.todos, hasLength(2));
    expect(find.text('Conteo guardado: 2 ajustes'), findsOneWidget);
  });

  testWidgets('a count typed before searching for another product is kept', (
    tester,
  ) async {
    await mostrar(tester);
    await tester.enterText(campoDe('Carne molida', 'Contado'), '3,4');
    await tester.enterText(
      find.widgetWithText(TextField, 'Buscar producto (Ctrl+K)'),
      'queso',
    );
    await tester.pump();
    expect(find.widgetWithText(FilaConteo, 'Carne molida'), findsNothing);
    await tester.enterText(campoDe('Queso blanco duro', 'Piezas'), '9');
    await tester.enterText(campoDe('Queso blanco duro', 'Peso'), '7,5');
    await tester.pump();
    expect(find.text('Guardar 2 ajustes'), findsOneWidget);
  });

  testWidgets('leaving without saving keeps what was typed', (tester) async {
    await mostrar(tester);
    await tester.enterText(campoDe('Carne molida', 'Contado'), '3,4');
    await tester.pumpWidget(const SizedBox());
    await mostrar(tester);
    expect(find.text('Guardar 1 ajuste'), findsOneWidget);
  });

  testWidgets('rows left empty change nothing', (tester) async {
    await mostrar(tester);
    expect(find.text('Guardar 0 ajustes'), findsOneWidget);
    await tester.enterText(campoDe('Carne molida', 'Contado'), '3,8');
    await tester.pump();
    expect(find.text('Guardar 0 ajustes'), findsOneWidget);
  });
}
