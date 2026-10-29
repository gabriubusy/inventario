import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';

/// "Lista Detal · Mayor · Especial  Alt+L" at the top of the sale window.
class SelectorListaPrecio extends StatelessWidget {
  const SelectorListaPrecio({
    super.key,
    required this.elegida,
    required this.onElegir,
  });

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
          Text(
            'Lista',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: colores.onSurfaceVariant,
            ),
          ),
          for (final lista in ListaPrecio.values)
            ChoiceChip(
              label: Text(lista.etiqueta),
              selected: lista == elegida,
              onSelected: (_) => onElegir(lista),
            ),
          TeclaAtajo('Alt+L cambia', color: colores.onSurfaceVariant),
        ],
      ),
    );
  }
}
