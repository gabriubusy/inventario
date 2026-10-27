import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/ajustes/domain/tipo_ajuste.dart';
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';

/// Alt+Q merma, Alt+W robo, in declaration order.
const teclasTipoAjuste = [LogicalKeyboardKey.keyQ, LogicalKeyboardKey.keyW];

class SelectorTipoAjuste extends StatelessWidget {
  const SelectorTipoAjuste({
    super.key,
    required this.elegido,
    required this.onElegir,
  });

  final TipoAjuste elegido;
  final ValueChanged<TipoAjuste> onElegir;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.espaciado.sm,
      children: [
        for (final tipo in TipoAjuste.values)
          Expanded(
            child: OpcionSeleccionable(
              titulo: tipo.etiqueta,
              detalle: 'Sale del stock',
              elegida: tipo == elegido,
              onPulsar: () => onElegir(tipo),
            ),
          ),
      ],
    );
  }
}
