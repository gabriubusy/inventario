import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/autenticacion/application/controlador_bloqueo.dart';
import 'package:inventario/features/autenticacion/domain/minutos_bloqueo.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';

/// Picks how long the app waits, with nobody touching it, before locking.
class SeccionBloqueo extends StatelessWidget {
  const SeccionBloqueo({super.key, required this.bloqueo});

  final ControladorBloqueo bloqueo;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: bloqueo,
    builder: (context, _) => ConEtiqueta(
      etiqueta: 'Bloquear solo si nadie lo usa',
      ayuda:
          'Pide el PIN otra vez tras ese rato sin tocar nada.\n'
          'Nunca: solo se bloquea con Ctrl+L.',
      child: Align(
        alignment: Alignment.centerLeft,
        child: SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            for (final minutos in MinutosBloqueo.opciones)
              ButtonSegment(
                value: minutos,
                label: Text(MinutosBloqueo.etiqueta(minutos)),
              ),
          ],
          selected: {bloqueo.minutos},
          onSelectionChanged: (valor) =>
              unawaited(bloqueo.cambiar(valor.first)),
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: context.espaciado.md),
            ),
          ),
        ),
      ),
    ),
  );
}
