import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';

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
    final colores = Theme.of(context).colorScheme;
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
        ExcludeFocus(
          child: SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: true,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: espaciado.sm,
                  children: [
                    Text('Abiertas · $abiertas'),
                    TeclaAtajo('Alt+A', color: colores.onSurfaceVariant),
                  ],
                ),
              ),
              ButtonSegment(
                value: false,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: espaciado.sm,
                  children: [
                    const Text('Todas'),
                    TeclaAtajo('Alt+T', color: colores.onSurfaceVariant),
                  ],
                ),
              ),
            ],
            selected: {soloAbiertas},
            onSelectionChanged: (valor) => onSoloAbiertas(valor.first),
          ),
        ),
      ],
    );
  }
}
