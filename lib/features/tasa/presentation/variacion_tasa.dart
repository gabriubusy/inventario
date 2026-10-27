import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/numeros.dart';

/// "▲ 0,17 %": how much the rate moved since the previous one. A rise means
/// the bolívar lost value, so it is drawn as a warning.
class VariacionTasa extends StatelessWidget {
  const VariacionTasa(this.variacion, {super.key});

  /// Hundredths of a percent, as `TasaCambio.variacion`.
  final int variacion;

  static String texto(int variacion) =>
      '${formatDecimal(variacion.abs(), decimales: 2, minDecimales: 2)} %';

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final alertas = context.coloresEstado;
    final espaciado = context.espaciado;
    final sube = variacion > 0;
    final fondo = sube ? alertas.fondoBajo : colores.surfaceContainerHighest;
    final color = sube ? alertas.textoBajo : colores.onSurfaceVariant;
    final icono = switch (variacion) {
      > 0 => Icons.arrow_upward,
      < 0 => Icons.arrow_downward,
      _ => Icons.remove,
    };
    final sentido = switch (variacion) {
      > 0 => 'Sube',
      < 0 => 'Baja',
      _ => 'Igual',
    };
    return Semantics(
      label: '$sentido ${texto(variacion)} desde la tasa anterior',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(espaciado.xxl),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: espaciado.sm,
            vertical: espaciado.xs / 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: espaciado.xs / 2,
            children: [
              Icon(icono, size: 14, color: color),
              Text(
                texto(variacion),
                style: tema.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
