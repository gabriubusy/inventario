import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/application/controlador_devoluciones.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/presentation/dialogo_ventas_hoy.dart';

void main() {
  const molida = Producto(
    id: 'p1',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 0,
    lotes: [LoteMarca(marca: 'Propia', cantidad: 10000, precio: 620)],
  );
  late ControladorExistencias existencias;
  late ControladorMovimientos movimientos;
  late ControladorSalidas salidas;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria([molida]),
    );
    await existencias.cargar();
    movimientos = ControladorMovimientos(RepositorioMovimientosEnMemoria());
    salidas = ControladorSalidas(existencias, movimientos: movimientos);
    await salidas.registrar(
      'p1',
      const Salida(marca: 'Propia', cantidad: 2000),
    );
  });

  tearDown(() {
    salidas.dispose();
    movimientos.dispose();
    existencias.dispose();
  });

  Future<void> abrir(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: DialogoVentasHoy(
            movimientos: movimientos,
            salidas: salidas,
            existencias: existencias,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('Supr asks first and Enter cancels the sale', (tester) async {
    await abrir(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();
    expect(find.text('¿Anular esta venta?'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(existencias.productos.single.lotes.single.cantidad, 10000);
    expect(find.text('Anulada'), findsOneWidget);
  });

  testWidgets('Esc keeps the sale', (tester) async {
    await abrir(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('¿Anular esta venta?'), findsNothing);
    expect(existencias.productos.single.lotes.single.cantidad, 8000);
    expect(movimientos.ventasDeHoy.single.anulada, isFalse);
  });

  testWidgets('Alt+D returns part of the sale to the stock', (tester) async {
    final devoluciones = ControladorDevoluciones(existencias, movimientos);
    addTearDown(devoluciones.dispose);
    await tester.binding.setSurfaceSize(const Size(1280, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: DialogoVentasHoy(
            movimientos: movimientos,
            salidas: salidas,
            existencias: existencias,
            devoluciones: devoluciones,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(find.text('Devolución de cliente'), findsOneWidget);
    expect(find.text('Se le devuelven \$ 12,40'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cuánto devuelve'),
      '0,5',
    );
    await tester.pump();
    expect(find.text('Se le devuelven \$ 3,10'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar devolución'));
    await tester.pumpAndSettle();
    expect(existencias.productos.single.lotes.single.cantidad, 8500);
    expect(movimientos.resumenDeHoy.vendido, 930);
  });

  testWidgets('the refund is recorded the way it is handed back', (
    tester,
  ) async {
    final devoluciones = ControladorDevoluciones(existencias, movimientos);
    addTearDown(devoluciones.dispose);
    await tester.binding.setSurfaceSize(const Size(1280, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: DialogoVentasHoy(
            movimientos: movimientos,
            salidas: salidas,
            existencias: existencias,
            devoluciones: devoluciones,
          ),
        ),
      ),
    );
    await tester.pump();
    Future<void> conAlt(LogicalKeyboardKey tecla) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(tecla);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pumpAndSettle();
    }

    await conAlt(LogicalKeyboardKey.keyD);
    await conAlt(LogicalKeyboardKey.digit3);
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar devolución'));
    await tester.pumpAndSettle();
    final devolucion = movimientos.todos.firstWhere((m) => m.origenId != null);
    expect(devolucion.medioReembolso, MedioPago.pagoMovil);
  });

  testWidgets('Alt+← shows the day before, where nothing is cancelled', (
    tester,
  ) async {
    await abrir(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(find.text('No hubo ventas ese día.'), findsOneWidget);
    expect(find.textContaining('Supr anular'), findsNothing);
  });
}
