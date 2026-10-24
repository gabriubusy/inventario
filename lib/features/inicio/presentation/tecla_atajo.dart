import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

/// A keycap like "F1", so shortcuts are visible where they apply.
class TeclaAtajo extends StatelessWidget {
  const TeclaAtajo(this.texto, {super.key, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(espaciado.xs),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: espaciado.xs + 2),
        child: Text(
          texto,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ),
    );
  }
}
