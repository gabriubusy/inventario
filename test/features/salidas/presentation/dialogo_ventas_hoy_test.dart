import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
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
}
