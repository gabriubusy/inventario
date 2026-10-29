import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

/// One bordered block of the Configuración page, with its title.
class BloqueConfiguracion extends StatelessWidget {
  const BloqueConfiguracion({
    super.key,
    required this.titulo,
    required this.child,
    this.detalle = '',
  });

  final String titulo;
  final String detalle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surfaceContainerLowest,
        border: Border.all(color: colores.outlineVariant),
        borderRadius: BorderRadius.circular(espaciado.md),
      ),
      child: Padding(
        padding: EdgeInsets.all(espaciado.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: espaciado.md,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (detalle.isNotEmpty)
                  Text(
                    detalle,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: colores.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}
