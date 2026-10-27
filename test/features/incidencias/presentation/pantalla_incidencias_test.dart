import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/data/repositorio_incidencias_en_memoria.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/incidencias/presentation/dialogo_incidencia.dart';
import 'package:inventario/features/incidencias/presentation/pantalla_incidencias.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

void main() {
  final hoy = DateTime(2026, 10, 26, 12);
  late ControladorExistencias existencias;
  late ControladorIncidencias incidencias;

  Incidencia incidencia(
    String id,
    int diasAtras,
    String proveedor,
    String producto, {
    RespuestaProveedor? respuesta,
  }) => Incidencia(
    id: id,
    fecha: hoy.subtract(Duration(days: diasAtras)),
    proveedor: proveedor,
    productoId: id,
    producto: producto,
    forma: FormaConteo.porKilo,
    marca: 'Propia',
    tipo: TipoIncidencia.vencido,
    cantidad: 1500,
    respuesta: respuesta,
  );

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const []),
    );
    await existencias.cargar();
    incidencias = ControladorIncidencias(
      RepositorioIncidenciasEnMemoria([
        incidencia('a', 0, 'Distribuidora 1', 'Queso blanco duro'),
        incidencia('b', 9, 'Frigorífico 1', 'Carne molida'),
        incidencia(
          'c',
          20,
          'Distribuidora 1',
          'Suero',
          respuesta: RespuestaProveedor.repuso,
        ),
      ]),
      existencias,
      ahora: () => hoy,
    );
    await incidencias.cargar();
  });

  tearDown(() {
    incidencias.dispose();
    existencias.dispose();
  });

  Future<void> mostrar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaIncidencias(
          incidencias: incidencias,
          existencias: existencias,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> conAlt(WidgetTester tester, LogicalKeyboardKey tecla) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(tecla);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
  }

  testWidgets('shows the open ones first, with overdue ones counted', (
    tester,
  ) async {
    await mostrar(tester);
    expect(find.text('Queso blanco duro · Propia'), findsOneWidget);
    expect(find.text('Carne molida · Propia'), findsOneWidget);
    expect(find.text('Suero · Propia'), findsNothing);
    expect(find.text('Abierta · 9 d'), findsOneWidget);
    await conAlt(tester, LogicalKeyboardKey.keyT);
    expect(find.text('Suero · Propia'), findsOneWidget);
  });

  testWidgets('Alt+1 answers the chosen one and Deshacer reopens it', (
    tester,
  ) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await conAlt(tester, LogicalKeyboardKey.digit1);
    final carne = incidencias.todas.firstWhere((i) => i.id == 'b');
    expect(carne.respuesta, RespuestaProveedor.repuso);
    expect(find.text('Carne molida · Propia'), findsNothing);

    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();
    expect(incidencias.todas.firstWhere((i) => i.id == 'b').abierta, isTrue);
  });

  testWidgets('the search finds by supplier', (tester) async {
    await mostrar(tester);
    await tester.enterText(find.byType(TextField), 'frigorifico');
    await tester.pumpAndSettle();
    expect(find.text('Queso blanco duro · Propia'), findsNothing);
    expect(find.text('Carne molida · Propia'), findsOneWidget);
  });

  testWidgets('Ctrl+N opens the window to register one', (tester) async {
    await mostrar(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoIncidencia), findsOneWidget);
  });
}
