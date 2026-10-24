import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/inicio/presentation/tecla_atajo.dart';

class BarraSuperior extends StatelessWidget {
  const BarraSuperior({super.key, required this.onBloquear});

  final VoidCallback onBloquear;

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
            DecoratedBox(
              decoration: BoxDecoration(
                color: colores.primary,
                borderRadius: BorderRadius.circular(espaciado.sm),
              ),
              child: Padding(
                padding: EdgeInsets.all(espaciado.sm),
                child: Icon(
                  Icons.storefront_outlined,
                  size: espaciado.xl - 4,
                  color: colores.onPrimary,
                ),
              ),
            ),
            Text(
              'Inventario',
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '· ${formatearFechaLarga(DateTime.now())}',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: colores.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onBloquear,
              icon: const Icon(Icons.lock_outline),
              label: Row(
                spacing: espaciado.sm,
                children: [
                  const Text('Bloquear'),
                  TeclaAtajo('Ctrl+L', color: colores.onSurfaceVariant),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
