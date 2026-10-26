import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/presentation/boton_tasa.dart';

class BarraProductos extends StatelessWidget {
  const BarraProductos({
    super.key,
    required this.resumen,
    required this.tasa,
    required this.onVolver,
    required this.onTasa,
    required this.onNuevo,
  });

  /// "9 productos · 2 con stock bajo · 2 agotados"
  final String resumen;
  final ControladorTasa tasa;
  final VoidCallback onVolver;
  final VoidCallback onTasa;
  final VoidCallback onNuevo;

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
              'Productos',
              style: tema.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: Text(
                resumen,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: colores.onSurfaceVariant,
                ),
              ),
            ),
            BotonTasa(controlador: tasa, onPulsar: onTasa),
            FilledButton.icon(
              onPressed: onNuevo,
              // The theme's full-width minimum would not fit in a Row.
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              icon: const Icon(Icons.add),
              label: Row(
                spacing: espaciado.sm,
                children: [
                  const Text('Nuevo producto'),
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
