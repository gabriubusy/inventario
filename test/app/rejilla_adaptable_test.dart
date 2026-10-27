import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/rejilla_adaptable.dart';

void main() {
  Future<int> filas(WidgetTester tester, double ancho) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: ancho,
            child: const RejillaAdaptable(
              anchoMinimo: 180,
              espacio: 10,
              children: [Text('a'), Text('b'), Text('c'), Text('d')],
            ),
          ),
        ),
      ),
    );
    return tester.widgetList(find.byType(Row)).length;
  }

  testWidgets('puts all four in one row when they fit', (tester) async {
    expect(await filas(tester, 760), 1);
  });

  testWidgets('splits four evenly into two rows, never three and one', (
    tester,
  ) async {
    expect(await filas(tester, 600), 2);
  });

  testWidgets('stacks them one per row when only one fits', (tester) async {
    expect(await filas(tester, 300), 4);
  });
}
