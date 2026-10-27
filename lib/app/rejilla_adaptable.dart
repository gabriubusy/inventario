import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lays [children] out in as many equal columns as fit at [anchoMinimo]
/// each, using only counts that split them evenly (4 → 4, 2 or 1).
class RejillaAdaptable extends StatelessWidget {
  const RejillaAdaptable({
    super.key,
    required this.anchoMinimo,
    required this.espacio,
    required this.children,
  });

  final double anchoMinimo;
  final double espacio;
  final List<Widget> children;

  int _columnas(double ancho) {
    final caben = ((ancho + espacio) / (anchoMinimo + espacio)).floor();
    var columnas = math.max(1, math.min(caben, children.length));
    while (children.length % columnas != 0) {
      columnas--;
    }
    return columnas;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, limites) {
        final columnas = _columnas(limites.maxWidth);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: espacio,
          children: [
            for (var i = 0; i < children.length; i += columnas)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: espacio,
                  children: [
                    for (final hijo in children.skip(i).take(columnas))
                      Expanded(child: hijo),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
