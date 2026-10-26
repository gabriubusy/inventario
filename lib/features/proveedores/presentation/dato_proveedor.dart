import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

/// A labelled contact detail in the supplier card; "—" when empty.
class DatoProveedor extends StatelessWidget {
  const DatoProveedor({super.key, required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surfaceContainerLowest,
        border: Border.all(color: colores.outlineVariant),
        borderRadius: BorderRadius.circular(espaciado.sm + 2),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.md,
          vertical: espaciado.sm + 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: espaciado.xs,
          children: [
            Text(
              etiqueta,
              style: tema.textTheme.bodySmall?.copyWith(
                color: colores.onSurfaceVariant,
              ),
            ),
            Text(
              valor.isEmpty ? '—' : valor,
              style: tema.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
