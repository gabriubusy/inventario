import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

enum PasoCambioPin {
  actual('1 · Actual', 'Escribe tu PIN actual'),
  nuevo('2 · Nuevo', 'Escribe el nuevo PIN'),
  repetir('3 · Repetir', 'Repite el nuevo PIN');

  const PasoCambioPin(this.etiqueta, this.titulo);

  final String etiqueta;
  final String titulo;
}

/// Three pills: done steps muted, the current one filled with the accent.
class PasosCambioPin extends StatelessWidget {
  const PasosCambioPin({super.key, required this.actual});

  final PasoCambioPin actual;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return Row(
      spacing: espaciado.sm,
      children: [
        for (final paso in PasoCambioPin.values)
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: paso == actual
                    ? colores.primary
                    : paso.index < actual.index
                    ? colores.surfaceContainerHighest
                    : colores.surface,
                border: paso.index > actual.index
                    ? Border.all(color: colores.outlineVariant)
                    : null,
                borderRadius: BorderRadius.circular(espaciado.xxl),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: espaciado.xs + 2),
                child: Text(
                  paso.etiqueta,
                  textAlign: TextAlign.center,
                  style: tema.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: paso == actual
                        ? colores.onPrimary
                        : colores.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
