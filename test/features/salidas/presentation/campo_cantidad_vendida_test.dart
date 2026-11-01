import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/entradas/presentation/controlador_cantidad.dart';
import 'package:inventario/features/salidas/presentation/campo_cantidad_vendida.dart';

void main() {
  late ControladorCantidad controller;
  late FocusNode foco;

  setUp(() {
    controller = ControladorCantidad();
    foco = FocusNode();
  });

  tearDown(() {
    controller.dispose();
    foco.dispose();
  });

  Future<void> mostrar(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: TemaApp.claro(),
      home: Scaffold(
        body: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => CampoCantidadVendida(
            etiqueta: 'Cantidad',
            controller: controller,
            focusNode: foco,
            decimales: 3,
            sufijo: 'kg',
            disponible: 10000,
            unidad: UnidadBase.kg,
            onEnviar: () {},
          ),
        ),
      ),
    ),
  );

  testWidgets('choosing g reads the typed number as grams', (tester) async {
    await mostrar(tester);
    await tester.enterText(find.byType(TextFormField), '250');
    expect(
      CampoCantidadVendida.leer(controller, 3, unidad: UnidadBase.kg),
      250000,
    );

    await tester.tap(find.text('g'));
    await tester.pump();

    expect(controller.enMinimo, isTrue);
    expect(
      CampoCantidadVendida.leer(controller, 3, unidad: UnidadBase.kg),
      250,
    );
  });

  testWidgets('hides the selector once a unit is typed', (tester) async {
    await mostrar(tester);
    await tester.enterText(find.byType(TextFormField), '250 g');
    await tester.pump();

    expect(find.byType(SegmentedButton<bool>), findsNothing);
  });
}
