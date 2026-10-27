import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';

/// "Total $ 53,27 · 47.266,47 Bs" and the Cobrar button.
class PieTicket extends StatelessWidget {
  const PieTicket({
    super.key,
    required this.total,
    required this.aBolivares,
    required this.onCobrar,
  });

  static const _altoBoton = 56.0;

  /// Dollar hundredths.
  final int total;
  final int? Function(int dolares) aBolivares;

  /// Null while there is nothing to charge.
  final VoidCallback? onCobrar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final bolivares = aBolivares(total);
    const cifras = [FontFeature.tabularFigures()];
    return Wrap(
      spacing: espaciado.lg,
      runSpacing: espaciado.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Wrap(
          spacing: espaciado.md,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              'Total',
              style: tema.textTheme.titleMedium?.copyWith(
                color: colores.onSurfaceVariant,
              ),
            ),
            Text(
              formatearDolares(total),
              style: tema.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: cifras,
              ),
            ),
            if (bolivares != null)
              Text(
                formatearBolivares(bolivares),
                style: tema.textTheme.titleMedium?.copyWith(
                  color: colores.onSurfaceVariant,
                  fontFeatures: cifras,
                ),
              ),
          ],
        ),
        FilledButton(
          onPressed: onCobrar,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, _altoBoton),
            padding: EdgeInsets.symmetric(horizontal: espaciado.xl),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: espaciado.md,
            children: [
              const Text('Cobrar'),
              TeclaAtajo('F10', color: colores.onPrimary),
            ],
          ),
        ),
      ],
    );
  }
}
