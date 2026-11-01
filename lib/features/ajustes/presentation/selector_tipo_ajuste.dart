import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/features/ajustes/domain/tipo_ajuste.dart';
import 'package:inventario/features/productos/presentation/interruptor_dos_opciones.dart';

/// Alt+Q merma, Alt+W robo, in declaration order.
const teclasTipoAjuste = [LogicalKeyboardKey.keyQ, LogicalKeyboardKey.keyW];

/// What each kind means, shown on hover over its label.
const ayudaTipoAjuste =
    'Los dos salen del stock\n'
    'Merma · Alt+Q\n'
    'Robo o pérdida · Alt+W';

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
    return InterruptorDosOpciones(
      primera: TipoAjuste.merma.etiqueta,
      segunda: TipoAjuste.robo.etiqueta,
      esSegunda: elegido == TipoAjuste.robo,
      onCambiar: (robo) => onElegir(robo ? TipoAjuste.robo : TipoAjuste.merma),
    );
  }
}
