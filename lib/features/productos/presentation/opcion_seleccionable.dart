import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';

/// A radio-like tile with its shortcut; the chosen one gets a light fill.
class OpcionSeleccionable extends StatelessWidget {
  const OpcionSeleccionable({
    super.key,
    required this.titulo,
    required this.atajo,
    required this.elegida,
    required this.onPulsar,
    this.detalle,
  });

  static const _alto = 44.0;

  final String titulo;
  final String? detalle;
  final String atajo;
  final bool elegida;
  final VoidCallback onPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final detalle = this.detalle;
    return Semantics(
      selected: elegida,
      child: OutlinedButton(
        onPressed: onPulsar,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(_alto),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(
            horizontal: espaciado.sm + 2,
            vertical: espaciado.sm,
          ),
          foregroundColor: colores.onSurface,
          backgroundColor: elegida
              ? colores.primary.withValues(alpha: 0.06)
              : colores.surface,
          side: BorderSide(
            color: elegida ? colores.primary : colores.outlineVariant,
            width: elegida ? 2 : 1,
          ),
        ),
        child: Row(
          spacing: espaciado.xs,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.labelLarge?.copyWith(
                      fontWeight: elegida ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (detalle != null)
                    Text(
                      detalle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            TeclaAtajo(atajo, color: colores.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
