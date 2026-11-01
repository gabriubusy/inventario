import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';

typedef EnlaceCabecera = ({String texto, String atajo, VoidCallback onPressed});

/// The links that stay in the header, side by side, each with its shortcut.
class EnlacesCabecera extends StatelessWidget {
  const EnlacesCabecera({super.key, required this.enlaces});

  final List<EnlaceCabecera> enlaces;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: espaciado.sm,
      children: [
        for (final enlace in enlaces)
          TextButton(
            onPressed: enlace.onPressed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: espaciado.sm,
              children: [
                Text(enlace.texto),
                TeclaAtajo(
                  enlace.atajo,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
