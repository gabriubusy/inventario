import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/presentation/campo_cantidad.dart';

/// "Avisar cuando queden (total)", the last field: Enter there saves.
class FilaMinimo extends StatelessWidget {
  const FilaMinimo({
    super.key,
    required this.controller,
    required this.forma,
    required this.decimales,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FormaConteo forma;
  final int decimales;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      spacing: context.espaciado.md,
      children: [
        Expanded(
          child: CampoCantidad(
            etiqueta: 'Avisar cuando queden (total)',
            controller: controller,
            decimales: decimales,
            sufijo: forma.cuentaPiezas ? 'piezas' : forma.unidad.simbolo,
            onSubmitted: onSubmitted,
          ),
        ),
        Expanded(
          child: Text(
            'Por debajo sale como "Stock bajo".',
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
