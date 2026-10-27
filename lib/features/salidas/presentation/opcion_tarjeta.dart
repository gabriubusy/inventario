import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

/// A selectable card with room for several lines. The chosen one gets the
/// accent border, a light fill and a check, so it reads at a glance.
class OpcionTarjeta extends StatelessWidget {
  const OpcionTarjeta({
    super.key,
    required this.elegida,
    required this.onPulsar,
    required this.child,
  });

  final bool elegida;
  final VoidCallback onPulsar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final espaciado = context.espaciado;
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(espaciado.sm + 2),
      side: BorderSide(
        color: elegida ? colores.primary : colores.outlineVariant,
        width: elegida ? 2 : 1,
      ),
    );
    return Semantics(
      selected: elegida,
      button: true,
      child: Material(
        color: elegida
            ? colores.primary.withValues(alpha: 0.06)
            : colores.surface,
        shape: forma,
        child: InkWell(
          onTap: onPulsar,
          customBorder: forma,
          child: Padding(
            padding: EdgeInsets.all(espaciado.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: espaciado.sm,
              children: [
                Expanded(child: child),
                // Same box either way, so choosing does not shift the text.
                Icon(
                  elegida ? Icons.check_circle : Icons.circle_outlined,
                  size: 20,
                  color: elegida ? colores.primary : colores.outlineVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
