import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

/// Replaces the way-of-counting picker while the product has stock:
/// switching pieces for litres would make the saved quantities meaningless.
class FormaBloqueada extends StatelessWidget {
  const FormaBloqueada({super.key, required this.forma});

  final FormaConteo forma;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surfaceContainerLowest,
        border: Border.all(color: colores.outlineVariant),
        borderRadius: BorderRadius.circular(espaciado.sm),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.md,
          vertical: espaciado.sm,
        ),
        child: Row(
          spacing: espaciado.md,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cómo se cuenta',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: colores.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    forma.etiqueta,
                    style: tema.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Text(
                'No se cambia mientras haya existencias',
                textAlign: TextAlign.right,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: colores.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
