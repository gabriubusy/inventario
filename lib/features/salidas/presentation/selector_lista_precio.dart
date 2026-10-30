import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';

/// "Lista ? Detal · Mayor · Especial" at the top of the sale window; the "?"
/// tells Alt+L.
class SelectorListaPrecio extends StatelessWidget {
  const SelectorListaPrecio({
    super.key,
    required this.elegida,
    required this.onElegir,
  });

  static const _tamanoAyuda = 16.0;

  final ListaPrecio elegida;
  final ValueChanged<ListaPrecio> onElegir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return ExcludeFocus(
      child: Wrap(
        spacing: espaciado.sm,
        runSpacing: espaciado.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Tooltip(
            message: 'Alt+L pasa a la siguiente lista y recalcula el ticket',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: espaciado.xs,
              children: [
                Text(
                  'Lista',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: colores.onSurfaceVariant,
                  ),
                ),
                Icon(
                  Icons.help_outline,
                  size: _tamanoAyuda,
                  color: colores.onSurfaceVariant,
                ),
              ],
            ),
          ),
          for (final lista in ListaPrecio.values)
            ChoiceChip(
              label: Text(lista.etiqueta),
              selected: lista == elegida,
              onSelected: (_) => onElegir(lista),
            ),
        ],
      ),
    );
  }
}
