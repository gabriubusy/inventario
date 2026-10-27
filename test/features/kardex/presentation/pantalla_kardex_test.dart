import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/kardex/presentation/fila_kardex.dart';
import 'package:inventario/features/kardex/presentation/pantalla_kardex.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  final ahora = DateTime(2026, 10, 27, 12);
  late ControladorExistencias existencias;
  late ControladorMovimientos movimientos;

  Movimiento mov(TipoMovimiento tipo, int horas, int cantidad, String nota) =>
      Movimiento(
        id: '$tipo$horas',
        fecha: ahora.subtract(Duration(hours: horas)),
        tipo: tipo,
        productoId: 'm',
        producto: 'Carne molida',
        forma: FormaConteo.porKilo,
        marca: 'Propia',
        cantidad: cantidad,
        nota: nota,
      );

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const [
        Producto(
          id: 'm',
          nombre: 'Carne molida',
          categoria: Categoria.carnes,
          forma: FormaConteo.porKilo,
          minimo: 8000,
          lotes: [LoteMarca(marca: 'Propia', cantidad: 3400)],
        ),
      ]),
    );
    await existencias.cargar();
    movimientos = ControladorMovimientos(
      RepositorioMovimientosEnMemoria([
        mov(TipoMovimiento.entrada, 4, 5000, ''),
        mov(TipoMovimiento.venta, 3, 1200, ''),
        mov(TipoMovimiento.merma, 1, 400, 'Recorte'),
      ]),
      ahora: () => ahora,
    );
    await movimientos.cargar();
  });

  tearDown(() {
    movimientos.dispose();
    existencias.dispose();
  });

  Future<void> mostrar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaKardex(
          movimientos: movimientos,
          existencias: existencias,
          productoId: 'm',
        ),
      ),
    );
  }

  testWidgets('lists every movement with the balance after it', (tester) async {
    await mostrar(tester);
    expect(find.byType(FilaKardex), findsNWidgets(3));
    expect(find.text('Propia · Recorte'), findsOneWidget);
    expect(find.text('3,8 kg'), findsWidgets);
    expect(find.text('5 kg'), findsWidgets);
  });

  testWidgets('Alt+4 shows only the losses', (tester) async {
    await mostrar(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(find.byType(FilaKardex), findsOneWidget);
  });

  testWidgets('without a product it starts on the search', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaKardex(
          movimientos: movimientos,
          existencias: existencias,
        ),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Producto'),
      'molida',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, 'Carne molida'));
    await tester.pumpAndSettle();
    expect(find.text('Kardex · Carne molida'), findsOneWidget);
  });
}
