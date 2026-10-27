import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

/// One figure of the day: a label, the figure and a quiet detail line.
class CifraDelDia extends StatelessWidget {
  const CifraDelDia({
    super.key,
    required this.titulo,
    required this.valor,
    required this.detalle,
    this.color,
  });

  final String titulo;
  final String valor;
  final String detalle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final suave = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.espaciado.lg,
          vertical: context.espaciado.md + 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: suave),
            Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              detalle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: suave,
            ),
          ],
        ),
      ),
    );
  }
}
