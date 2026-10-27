import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/data/almacen_imagenes_en_memoria.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/dialogo_nuevo_producto.dart';

void main() {
  const arroz = Producto(
    id: 'p1',
    nombre: 'Arroz',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 0,
    lotes: [LoteMarca(marca: 'Mary', cantidad: 24000)],
  );
  late ControladorExistencias controlador;

  setUp(() async {
    controlador = ControladorExistencias(
      RepositorioProductosEnMemoria([arroz]),
    );
    await controlador.cargar();
  });

  tearDown(() => controlador.dispose());

  Future<void> editar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => unawaited(
                mostrarDialogoEditarProducto(
                  context,
                  controlador,
                  producto: arroz,
                  fotos: GestorFotos(AlmacenImagenesEnMemoria()),
                  alEditar: (_, _) {},
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> altSupr(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
  }

  testWidgets('Alt+Supr asks, says what stock is left, and Enter deletes', (
    tester,
  ) async {
    await editar(tester);
    await altSupr(tester);
    expect(find.text('¿Borrar «Arroz»?'), findsOneWidget);
    expect(find.textContaining('Todavía hay 24 kg'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(controlador.productos, isEmpty);
    expect(find.text('Editar producto'), findsNothing);
    expect(find.text('Producto borrado · Arroz'), findsOneWidget);
  });

  testWidgets('Esc keeps the product and the window', (tester) async {
    await editar(tester);
    await altSupr(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(controlador.productos, [arroz]);
    expect(find.text('Editar producto'), findsOneWidget);
  });
}
