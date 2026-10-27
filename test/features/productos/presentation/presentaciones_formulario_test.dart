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
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/dialogo_nuevo_producto.dart';

void main() {
  late ControladorExistencias controlador;

  setUp(() async {
    controlador = ControladorExistencias(
      RepositorioProductosEnMemoria(const [
        Producto(
          id: 'p1',
          nombre: 'Arroz',
          categoria: Categoria.carnes,
          forma: FormaConteo.porKilo,
          minimo: 0,
          presentaciones: [
            Presentacion(
              nombre: 'Bulto',
              factor: 24000,
              precio: 2400,
              codigo: 'ARROZ-24',
            ),
          ],
        ),
      ]),
    );
    await controlador.cargar();
  });

  tearDown(() => controlador.dispose());

  Future<void> abrir(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => unawaited(
                mostrarDialogoNuevoProducto(
                  context,
                  controlador,
                  fotos: GestorFotos(AlmacenImagenesEnMemoria()),
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

  Finder campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

  Future<void> ctrlP(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
  }

  Producto? creado(String nombre) =>
      controlador.productos.where((p) => p.nombre == nombre).firstOrNull;

  testWidgets('a product gets two packs, the first one by default', (
    tester,
  ) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre').first, 'Alimento para perro');
    await ctrlP(tester);
    await tester.enterText(campo('Nombre').last, 'Saco');
    await tester.enterText(campo('Contiene').last, '15');
    await tester.enterText(campo('Código').last, '7591234000011');
    await tester.enterText(campo('Precio').last, '30');
    await ctrlP(tester);
    await tester.enterText(campo('Nombre').last, 'Kilo');
    await tester.enterText(campo('Contiene').last, '1');
    await tester.enterText(campo('Precio').last, '2,20');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();

    expect(creado('Alimento para perro')?.presentaciones, const [
      Presentacion(
        nombre: 'Saco',
        factor: 15000,
        precio: 3000,
        codigo: '7591234000011',
        predeterminada: true,
      ),
      Presentacion(nombre: 'Kilo', factor: 1000, precio: 220),
    ]);
  });

  testWidgets('the star moves the default to another pack', (tester) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre').first, 'Arroz suelto');
    await ctrlP(tester);
    await tester.enterText(campo('Nombre').last, 'Bulto');
    await tester.enterText(campo('Contiene').last, '24');
    await tester.enterText(campo('Precio').last, '24');
    await ctrlP(tester);
    await tester.enterText(campo('Nombre').last, 'Kilo');
    await tester.enterText(campo('Contiene').last, '1');
    await tester.enterText(campo('Precio').last, '1,10');
    await tester.tap(find.byIcon(Icons.star_border).last);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();

    final predeterminada = creado('Arroz suelto')?.presentacionPredeterminada;
    expect(predeterminada?.nombre, 'Kilo');
  });

  testWidgets('a code another product uses is refused', (tester) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre').first, 'Arroz blanco');
    await ctrlP(tester);
    await tester.enterText(campo('Nombre').last, 'Bulto');
    await tester.enterText(campo('Contiene').last, '24');
    await tester.enterText(campo('Código').last, 'arroz-24');
    await tester.enterText(campo('Precio').last, '24');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();
    expect(find.text('Lo usa otro producto'), findsOneWidget);
    expect(creado('Arroz blanco'), isNull);
  });

  testWidgets('products in pieces have no packs', (tester) async {
    await abrir(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyQ);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(find.text('Presentaciones'), findsNothing);
  });
}
