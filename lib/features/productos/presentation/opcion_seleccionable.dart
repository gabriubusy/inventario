import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

/// A radio-like tile; the chosen one gets a light fill. Its keyboard shortcut
/// is not drawn inside: it ate the space and cut the words short.
class OpcionSeleccionable extends StatelessWidget {
  const OpcionSeleccionable({
    super.key,
    required this.titulo,
    required this.elegida,
    required this.onPulsar,
    this.detalle,
    this.ayuda,
  });

  static const _alto = 44.0;
  static const _tamanoAyuda = 16.0;

  final String titulo;

  /// Always-visible second line, for facts the user needs at a glance.
  final String? detalle;

  /// Explanation behind a "?" shown on hover, for what is only a reminder.
  final String? ayuda;
  final bool elegida;
  final VoidCallback onPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final detalle = this.detalle;
    final ayuda = this.ayuda;
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
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: espaciado.xs,
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.labelLarge?.copyWith(
                        fontWeight: elegida ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (ayuda != null)
                    Tooltip(
                      message: ayuda,
                      child: Icon(
                        Icons.help_outline,
                        size: _tamanoAyuda,
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                ],
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
      ),
    );
  }
}
