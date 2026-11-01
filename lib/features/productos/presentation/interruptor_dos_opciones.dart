import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

/// A switch between exactly two named options: off picks [primera], on
/// picks [segunda]. Either name can be clicked too.
class InterruptorDosOpciones extends StatelessWidget {
  const InterruptorDosOpciones({
    super.key,
    required this.primera,
    required this.segunda,
    required this.esSegunda,
    required this.onCambiar,
  });

  final String primera;
  final String segunda;
  final bool esSegunda;

  /// Receives true when [segunda] is chosen.
  final ValueChanged<bool> onCambiar;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: context.espaciado.sm,
      children: [
        _NombreOpcion(
          texto: primera,
          elegida: !esSegunda,
          onPulsar: () => onCambiar(false),
        ),
        Semantics(
          label: '$primera o $segunda',
          child: Switch(
            value: esSegunda,
            onChanged: onCambiar,
            // Both sides are valid choices, so "off" must not look disabled.
            inactiveThumbColor: colores.primary,
            inactiveTrackColor: colores.primary.withValues(alpha: 0.12),
            trackOutlineColor: WidgetStatePropertyAll(colores.primary),
          ),
        ),
        _NombreOpcion(
          texto: segunda,
          elegida: esSegunda,
          onPulsar: () => onCambiar(true),
        ),
      ],
    );
  }
}

class _NombreOpcion extends StatelessWidget {
  const _NombreOpcion({
    required this.texto,
    required this.elegida,
    required this.onPulsar,
  });

  final String texto;
  final bool elegida;
  final VoidCallback onPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    return Semantics(
      selected: elegida,
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPulsar,
          child: Text(
            texto,
            style: tema.textTheme.labelLarge?.copyWith(
              color: elegida ? colores.primary : colores.onSurfaceVariant,
              fontWeight: elegida ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
