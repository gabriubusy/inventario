import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

/// "Sacar del inventario" with what the brand will have left.
class CasillaSacar extends StatelessWidget {
  const CasillaSacar({
    super.key,
    required this.marcada,
    required this.detalle,
    required this.onCambiar,
  });

  final bool marcada;

  /// "Marca A quedará en 8 piezas · 6,6 kg"; null while nothing is typed.
  final String? detalle;
  final ValueChanged<bool> onCambiar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final detalle = this.detalle;
    return ExcludeFocus(
      child: InkWell(
        onTap: () => onCambiar(!marcada),
        borderRadius: BorderRadius.circular(espaciado.sm),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colores.surfaceContainerLowest,
            border: Border.all(color: colores.outlineVariant),
            borderRadius: BorderRadius.circular(espaciado.sm),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: espaciado.sm,
              vertical: espaciado.xs,
            ),
            child: Row(
              children: [
                Checkbox(
                  value: marcada,
                  onChanged: (valor) => onCambiar(valor ?? false),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sacar del inventario',
                        style: tema.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        marcada
                            ? detalle ?? 'Se descuenta de la marca elegida'
                            : 'El inventario no cambia',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: colores.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
