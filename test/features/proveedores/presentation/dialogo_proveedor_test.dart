import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/data/repositorio_proveedores_en_memoria.dart';
import 'package:inventario/features/proveedores/presentation/dialogo_proveedor.dart';

void main() {
  late ControladorExistencias existencias;
  late ControladorProveedores controlador;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const []),
    );
    await existencias.cargar();
    controlador = ControladorProveedores(
      RepositorioProveedoresEnMemoria(const []),
      existencias,
    );
    await controlador.cargar();
  });

  tearDown(() {
    controlador.dispose();
    existencias.dispose();
  });

  Future<void> abrir(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  unawaited(mostrarDialogoProveedor(context, controlador)),
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

  Future<void> crear(WidgetTester tester, String telefono) async {
    await abrir(tester);
    await tester.enterText(campo('Nombre'), 'Distribuidora 1');
    await tester.enterText(campo('Teléfono (opcional)'), telefono);
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();
  }

  testWidgets('a phone that cannot be dialled is not saved', (tester) async {
    await crear(tester, '0414-123');
    expect(find.text('Ej.: 0414-000.00.00'), findsOneWidget);
    expect(controlador.visibles, isEmpty);
  });

  testWidgets('a Venezuelan number is saved', (tester) async {
    await crear(tester, '0414-123.45.67');
    expect(controlador.visibles.single.telefono, '0414-123.45.67');
  });

  testWidgets('no phone is still a supplier', (tester) async {
    await crear(tester, '');
    expect(controlador.visibles.single.nombre, 'Distribuidora 1');
  });
}
