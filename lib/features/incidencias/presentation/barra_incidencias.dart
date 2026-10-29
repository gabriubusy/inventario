import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';

class BarraIncidencias extends StatelessWidget {
  const BarraIncidencias({
    super.key,
    required this.onVolver,
    required this.onNueva,
    this.onDevoluciones,
  });

  final VoidCallback onVolver;
  final VoidCallback onNueva;

  /// Opens the list of goods sent back to suppliers (Alt+D).
  final VoidCallback? onDevoluciones;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final onDevoluciones = this.onDevoluciones;
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
            Expanded(
              child: Text(
                'Incidencias con proveedores',
                style: tema.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onDevoluciones != null)
              TextButton(
                onPressed: onDevoluciones,
                child: Row(
                  spacing: espaciado.sm,
                  children: [
                    const Text('Devoluciones'),
                    TeclaAtajo('Alt+D', color: colores.onSurfaceVariant),
                  ],
                ),
              ),
            FilledButton.icon(
              onPressed: onNueva,
              // The theme's full-width minimum would not fit in a Row.
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              icon: const Icon(Icons.add),
              label: Row(
                spacing: espaciado.sm,
                children: [
                  const Text('Registrar incidencia'),
                  TeclaAtajo('Ctrl+N', color: colores.onPrimary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
