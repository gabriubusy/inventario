import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';

class EncabezadoDialogo extends StatelessWidget {
  const EncabezadoDialogo({
    super.key,
    required this.titulo,
    this.icono = Icons.inventory_2_outlined,
  });

  final String titulo;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return Row(
      spacing: espaciado.md,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colores.primaryContainer,
            borderRadius: BorderRadius.circular(espaciado.sm + 2),
          ),
          child: Padding(
            padding: EdgeInsets.all(espaciado.sm),
            child: Icon(icono, color: colores.onPrimaryContainer),
          ),
        ),
        Expanded(
          child: Text(
            titulo,
            style: tema.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Row(
            spacing: espaciado.sm,
            children: [
              TeclaAtajo('Esc', color: colores.onSurfaceVariant),
              Icon(Icons.close, color: colores.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }
}
