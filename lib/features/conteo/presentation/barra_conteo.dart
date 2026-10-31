import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';

/// Back, title, search and "Guardar N ajustes".
class BarraConteo extends StatelessWidget {
  const BarraConteo({
    super.key,
    required this.busqueda,
    required this.focoBusqueda,
    required this.cambios,
    required this.guardando,
    required this.onVolver,
    required this.onGuardar,
  });

  static const _anchoBuscador = 300.0;

  final TextEditingController busqueda;
  final FocusNode focoBusqueda;

  /// Rows whose count differs from the system.
  final int cambios;
  final bool guardando;
  final VoidCallback onVolver;
  final VoidCallback onGuardar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surface,
        border: Border(bottom: BorderSide(color: colores.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.xxl,
          vertical: espaciado.md,
        ),
        child: Row(
          spacing: espaciado.md,
          children: [
            TextButton.icon(
              onPressed: onVolver,
              icon: const Icon(Icons.arrow_back),
              label: Row(
                spacing: espaciado.sm,
                children: [
                  const Text('Inicio'),
                  TeclaAtajo('Esc', color: colores.onSurfaceVariant),
                ],
              ),
            ),
            Text(
              'Conteo físico',
              maxLines: 1,
              softWrap: false,
              style: tema.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            // The search gives way first when the window is narrow.
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _anchoBuscador),
                  child: TextField(
                    controller: busqueda,
                    focusNode: focoBusqueda,
                    decoration: const InputDecoration(
                      hintText: 'Buscar producto (Ctrl+K)',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ),
            FilledButton(
              onPressed: guardando || cambios == 0 ? null : onGuardar,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              child: Row(
                spacing: espaciado.sm,
                children: [
                  Text(
                    cambios == 1
                        ? 'Guardar 1 ajuste'
                        : 'Guardar $cambios ajustes',
                  ),
                  TeclaAtajo('Ctrl+S', color: colores.onPrimary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
