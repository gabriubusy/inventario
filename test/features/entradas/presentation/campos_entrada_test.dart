import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/entradas/presentation/campos_entrada.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

void main() {
  testWidgets('a new brand lets the supplier be picked from a list', (
    tester,
  ) async {
    final controladores = List.generate(5, (_) => TextEditingController());
    final focos = List.generate(4, (_) => FocusNode());
    addTearDown(() {
      for (final c in controladores) {
        c.dispose();
      }
      for (final f in focos) {
        f.dispose();
      }
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: CamposEntrada(
            forma: FormaConteo.piezasYKilos,
            lote: null,
            marca: controladores[0],
            proveedor: controladores[1],
            piezas: controladores[2],
            cantidad: controladores[3],
            nota: controladores[4],
            focoMarca: focos[0],
            focoProveedor: focos[1],
            focoPiezas: focos[2],
            focoCantidad: focos[3],
            proveedores: const ['Distribuidora 1', 'Lácteos 1'],
            onEnviar: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Ver proveedores'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Lácteos 1'));
    await tester.pump();
    expect(controladores[1].text, 'Lácteos 1');
  });
}
