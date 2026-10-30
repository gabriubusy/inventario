import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';

/// Alt+A, S, D, F pick the reasons in order.
const teclasMotivo = [
  LogicalKeyboardKey.keyA,
  LogicalKeyboardKey.keyS,
  LogicalKeyboardKey.keyD,
  LogicalKeyboardKey.keyF,
];

/// Each reason with its shortcut, for its label's hover help.
String ayudaMotivos(List<String> motivos) =>
    lineasAyuda(motivos, const ['Alt+A', 'Alt+S', 'Alt+D', 'Alt+F']).join('\n');

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
