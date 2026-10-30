import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';

/// Alt+Q, W, E, R pick each way of counting, in declaration order.
const teclasFormaConteo = [
  (LogicalKeyboardKey.keyQ, 'Q'),
  (LogicalKeyboardKey.keyW, 'W'),
  (LogicalKeyboardKey.keyE, 'E'),
  (LogicalKeyboardKey.keyR, 'R'),
];

/// Each way of counting with an example and its shortcut, for its label.
final ayudaFormaConteo = [
  for (final (i, forma) in FormaConteo.values.indexed)
    '${forma.etiqueta}: ${forma.ejemplo.toLowerCase()} · '
        'Alt+${teclasFormaConteo[i].$2}',
].join('\n');

class SelectorFormaConteo extends StatelessWidget {
  const SelectorFormaConteo({
    super.key,
    required this.elegida,
    required this.onElegir,
  });

  final FormaConteo elegida;
  final ValueChanged<FormaConteo> onElegir;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.espaciado.sm,
      children: [
        for (final forma in FormaConteo.values)
          Expanded(
            child: OpcionSeleccionable(
              titulo: forma.etiqueta,
              elegida: forma == elegida,
              onPulsar: () => onElegir(forma),
            ),
          ),
      ],
    );
  }
}
