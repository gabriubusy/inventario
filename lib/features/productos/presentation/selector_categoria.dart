import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';

/// Picked with the mouse or Alt+1…; the dialog owns the shortcuts.
class SelectorCategoria extends StatelessWidget {
  const SelectorCategoria({
    super.key,
    required this.elegida,
    required this.onElegir,
  });

  final Categoria elegida;
  final ValueChanged<Categoria> onElegir;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.espaciado.sm,
      children: [
        for (final categoria in Categoria.values)
          Expanded(
            child: OpcionSeleccionable(
              titulo: categoria.etiqueta,
              elegida: categoria == elegida,
              onPulsar: () => onElegir(categoria),
            ),
          ),
      ],
    );
  }
}
