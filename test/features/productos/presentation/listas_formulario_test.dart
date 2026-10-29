import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/data/almacen_imagenes_en_memoria.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/regla_precio.dart';
import 'package:inventario/features/productos/presentation/dialogo_nuevo_producto.dart';

void main() {
  late ControladorExistencias controlador;

  setUp(() async {
    controlador = ControladorExistencias(
      RepositorioProductosEnMemoria(const []),
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

  Producto? creado(String nombre) =>
      controlador.productos.where((p) => p.nombre == nombre).firstOrNull;

  testWidgets(
    'Alt+L gives Mayor a margin over cost and shows what it ends at',
    (tester) async {
      await abrir(tester);
      await tester.enterText(campo('Nombre').first, 'Harina');
      await tester.enterText(campo('Marca'), 'Propia');
      await tester.enterText(campo('Cantidad'), '10');
      await tester.enterText(campo('Costo'), '4');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pumpAndSettle();
      tester.testTextInput.enterText('25');
      await tester.pump();
      expect(find.textContaining('Queda Propia'), findsOneWidget);
      expect(find.textContaining('5,00'), findsWidgets);

      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Crear'));

      await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
      await tester.pumpAndSettle();
      expect(creado('Harina')?.reglas, {
        ListaPrecio.mayor: const MargenSobreCosto(2500),
      });
    },
  );

  testWidgets('a fixed price for Especial is saved as is', (tester) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre').first, 'Azúcar');
    await tester.tap(find.text('Poner precios'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Precio fijo').last);
    await tester.pumpAndSettle();
    tester.testTextInput.enterText('1,80');
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Crear'));
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();
    expect(creado('Azúcar')?.reglas, {
      ListaPrecio.especial: const PrecioFijo(180),
    });
  });
}
