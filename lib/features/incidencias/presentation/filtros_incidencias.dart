import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

/// Search plus the Abiertas / Todas switch.
class FiltrosIncidencias extends StatelessWidget {
  const FiltrosIncidencias({
    super.key,
    required this.busqueda,
    required this.focoBusqueda,
    required this.soloAbiertas,
    required this.abiertas,
    required this.onSoloAbiertas,
  });

  static const _anchoBusqueda = 360.0;

  final TextEditingController busqueda;
  final FocusNode focoBusqueda;
  final bool soloAbiertas;

  /// Shown on the "Abiertas" option.
  final int abiertas;
  final ValueChanged<bool> onSoloAbiertas;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return Row(
      spacing: espaciado.md,
      children: [
        SizedBox(
          width: _anchoBusqueda,
          child: TextField(
            controller: busqueda,
            focusNode: focoBusqueda,
            decoration: const InputDecoration(
              hintText: 'Buscar proveedor, producto o marca (Ctrl+K)',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
        Tooltip(
          message: 'Abiertas · Alt+A\nTodas · Alt+T',
          child: ExcludeFocus(
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: true, label: Text('Abiertas · $abiertas')),
                const ButtonSegment(value: false, label: Text('Todas')),
              ],
              selected: {soloAbiertas},
              onSelectionChanged: (valor) => onSoloAbiertas(valor.first),
            ),
          ),
        ),
      ],
    );
  }
}
