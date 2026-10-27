import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';

/// Alt+Q, W, E, R, T pick each kind, in declaration order.
const teclasTipoIncidencia = [
  LogicalKeyboardKey.keyQ,
  LogicalKeyboardKey.keyW,
  LogicalKeyboardKey.keyE,
  LogicalKeyboardKey.keyR,
  LogicalKeyboardKey.keyT,
];

class SelectorTipoIncidencia extends StatelessWidget {
  const SelectorTipoIncidencia({
    super.key,
    required this.elegido,
    required this.onElegir,
  });

  static const _columnas = 3;

  final TipoIncidencia elegido;
  final ValueChanged<TipoIncidencia> onElegir;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return LayoutBuilder(
      builder: (context, limites) {
        final ancho =
            (limites.maxWidth - espaciado.sm * (_columnas - 1)) / _columnas;
        return Wrap(
          spacing: espaciado.sm,
          runSpacing: espaciado.sm,
          children: [
            for (final tipo in TipoIncidencia.values)
              SizedBox(
                width: ancho,
                child: OpcionSeleccionable(
                  titulo: tipo.etiqueta,
                  elegida: tipo == elegido,
                  onPulsar: () => onElegir(tipo),
                ),
              ),
          ],
        );
      },
    );
  }
}
