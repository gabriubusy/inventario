import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';

/// Alt+A, S, D, F pick the reasons in order.
const teclasMotivo = [
  LogicalKeyboardKey.keyA,
  LogicalKeyboardKey.keyS,
  LogicalKeyboardKey.keyD,
  LogicalKeyboardKey.keyF,
];

class SelectorMotivo extends StatelessWidget {
  const SelectorMotivo({
    super.key,
    required this.motivos,
    required this.elegido,
    required this.onElegir,
  });

  final List<String> motivos;
  final String elegido;
  final ValueChanged<String> onElegir;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.espaciado.sm,
      runSpacing: context.espaciado.sm,
      children: [
        for (final motivo in motivos)
          ChoiceChip(
            label: Text(motivo),
            selected: motivo == elegido,
            showCheckmark: false,
            onSelected: (_) => onElegir(motivo),
          ),
      ],
    );
  }
}
