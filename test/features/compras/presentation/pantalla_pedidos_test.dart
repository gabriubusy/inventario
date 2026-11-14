import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/data/repositorio_compras_en_memoria.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/estado_pedido.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/compras/presentation/pantalla_pedidos.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  const molida = Producto(
    id: 'm',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 8000,
    lotes: [
      LoteMarca(
        marca: 'Propia',
        proveedor: 'Frigorífico 1',
        cantidad: 3800,
        costo: 450,
      ),
    ],
  );
  const linea = LineaCompra(
    productoId: 'm',
    producto: 'Carne molida',
    forma: FormaConteo.porKilo,
    marca: 'Propia',
    cantidad: 10000,
    costo: 450,
  );
  final hoy = DateTime(2026, 11, 12, 10);
  late ControladorExistencias existencias;
  late ControladorMovimientos movimientos;
  late ControladorCompras compras;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const [molida]),
    );
    await existencias.cargar();
    movimientos = ControladorMovimientos(RepositorioMovimientosEnMemoria());
    compras = ControladorCompras(
      RepositorioComprasEnMemoria(),
      existencias,
      movimientos: movimientos,
      tasaDeHoy: () => 88623,
      ahora: () => hoy,
    );
    await compras.cargar();
    await compras.registrar(
      Compra(
        fecha: hoy,
        proveedor: 'Frigorífico 1',
        factura: '1240',
        lineas: const [linea],
        vence: DateTime(2026, 11, 27),
      ),
    );
  });

  tearDown(() {
    compras.dispose();
    movimientos.dispose();
    existencias.dispose();
  });

  Future<void> abrir(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaPedidos(compras: compras),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> teclear(WidgetTester tester, LogicalKeyboardKey tecla) async {
    await tester.sendKeyEvent(tecla);
    await tester.pumpAndSettle();
  }

  Future<void> conControl(WidgetTester tester, LogicalKeyboardKey tecla) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(tecla);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
  }

  LoteMarca lote() => existencias.productos.single.lotes.single;

  testWidgets('the table lists what is still waiting', (tester) async {
    await abrir(tester);
    expect(find.text('Frigorífico 1'), findsOneWidget);
    expect(find.text('1240'), findsOneWidget);
    expect(find.text('Pendiente'), findsWidgets);
  });

  testWidgets('Enter opens the panel with what was ordered', (tester) async {
    await abrir(tester);
    await teclear(tester, LogicalKeyboardKey.enter);
    expect(find.textContaining('Qué llegó de Frigorífico 1'), findsOneWidget);
    final campo = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Llegó'),
    );
    expect(campo.controller?.text, '10');
    expect(find.text('Cuadra'), findsWidgets);
  });

  testWidgets('Ctrl+S puts what arrived into the stock', (tester) async {
    await abrir(tester);
    await teclear(tester, LogicalKeyboardKey.enter);
    await conControl(tester, LogicalKeyboardKey.keyS);
    expect(lote().cantidad, 13800);
    expect(movimientos.todos.single.nota, 'Factura 1240');
    expect(compras.compras.single.estado, EstadoPedido.recibido);
    expect(find.textContaining('Recibido · Frigorífico 1'), findsOneWidget);
  });

  testWidgets('less than ordered is saved as a difference', (tester) async {
    await abrir(tester);
    await teclear(tester, LogicalKeyboardKey.enter);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Llegó'),
      '9,400',
    );
    await tester.pumpAndSettle();
    expect(find.text('−0,6 kg'), findsOneWidget);
    await conControl(tester, LogicalKeyboardKey.keyS);
    expect(lote().cantidad, 13200);
    expect(compras.compras.single.estado, EstadoPedido.conDiferencias);
  });

  testWidgets('Esc closes the panel without receiving anything', (
    tester,
  ) async {
    await abrir(tester);
    await teclear(tester, LogicalKeyboardKey.enter);
    await teclear(tester, LogicalKeyboardKey.escape);
    expect(find.textContaining('Qué llegó de'), findsNothing);
    expect(lote(), molida.lotes.single);
    expect(find.text('Confirmar lo que llegó'), findsOneWidget);
  });

  testWidgets('Deshacer takes the goods back out', (tester) async {
    await abrir(tester);
    await teclear(tester, LogicalKeyboardKey.enter);
    await conControl(tester, LogicalKeyboardKey.keyS);
    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();
    expect(lote(), molida.lotes.single);
    expect(compras.compras.single.estado, EstadoPedido.pendiente);
  });

  testWidgets('Alt+3 shows the ones already received', (tester) async {
    await abrir(tester);
    await teclear(tester, LogicalKeyboardKey.enter);
    await conControl(tester, LogicalKeyboardKey.keyS);
    expect(find.text('No hay pedidos por recibir'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(find.text('Frigorífico 1'), findsOneWidget);
    expect(find.text('Recibido'), findsWidgets);
  });
}
