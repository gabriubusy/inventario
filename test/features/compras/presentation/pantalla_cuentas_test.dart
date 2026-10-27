import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/data/repositorio_compras_en_memoria.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/compras/presentation/fila_cuenta.dart';
import 'package:inventario/features/compras/presentation/pantalla_cuentas.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

void main() {
  final hoy = DateTime(2026, 10, 27, 12);
  late ControladorExistencias existencias;
  late ControladorCompras compras;

  Compra factura(String id, String proveedor, int dias, int costo) => Compra(
    id: id,
    fecha: hoy.subtract(const Duration(days: 20)),
    proveedor: proveedor,
    factura: id,
    lineas: [
      LineaCompra(
        productoId: 'm',
        producto: 'Carne molida',
        forma: FormaConteo.porKilo,
        marca: 'Propia',
        cantidad: 1000,
        costo: costo,
      ),
    ],
    vence: hoy.add(Duration(days: dias)),
  );

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const []),
    );
    compras = ControladorCompras(
      RepositorioComprasEnMemoria(
        compras: [
          factura('A-1', 'Frigorífico 1', -3, 14000),
          factura('B-2', 'Distribuidora 2', 12, 24500),
        ],
      ),
      existencias,
      tasaDeHoy: () => 88623,
      ahora: () => hoy,
    );
    await compras.cargar();
  });

  tearDown(() {
    compras.dispose();
    existencias.dispose();
  });

  Future<void> mostrar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaCuentas(compras: compras),
      ),
    );
  }

  testWidgets('lists what is owed, the overdue one first', (tester) async {
    await mostrar(tester);
    expect(find.byType(FilaCuenta), findsNWidgets(2));
    expect(find.text('Vencida · 3 d'), findsOneWidget);
    expect(find.text(r'$ 385,00'), findsOneWidget);
  });

  testWidgets('Alt+P then Alt+T pays the chosen invoice in full', (
    tester,
  ) async {
    await mostrar(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(find.text('Pagar a Frigorífico 1'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(find.text('Pago completo: la factura queda pagada'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar pago'));
    await tester.pumpAndSettle();
    expect(compras.deudaDe('Frigorífico 1'), 0);
    expect(find.byType(FilaCuenta), findsOneWidget);
  });

  testWidgets('a payment in bolívares shows what it covers', (tester) async {
    await mostrar(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Monto en Bs'),
      '44.311,50',
    );
    await tester.pump();
    expect(find.text(r'= $ 50,00'), findsOneWidget);
    expect(
      find.text(r'Abono de $ 50,00 · quedará debiendo $ 90,00'),
      findsOneWidget,
    );
  });
}
