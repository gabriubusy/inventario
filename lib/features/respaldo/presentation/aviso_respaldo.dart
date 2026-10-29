import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/respaldo/application/controlador_respaldo.dart';

/// "Hace 9 días que no respaldas" under the header, with Respaldar ahora
/// (Ctrl+B) and Mañana. Hidden while there is nothing to remind.
class AvisoRespaldo extends StatelessWidget {
  const AvisoRespaldo({
    super.key,
    required this.respaldo,
    required this.onRespaldar,
  });

  final ControladorRespaldo respaldo;
  final VoidCallback onRespaldar;

  String get _texto => switch (respaldo.diasSinRespaldo) {
    null => 'Nunca has hecho un respaldo.',
    0 || 1 => 'Hace 1 día que no respaldas.',
    final dias => 'Hace $dias días que no respaldas.',
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: respaldo,
      builder: (context, _) {
        if (!respaldo.hayQueRecordar) return const SizedBox.shrink();
        final alertas = context.coloresEstado;
        final espaciado = context.espaciado;
        return Semantics(
          liveRegion: true,
          child: ColoredBox(
            color: alertas.fondoBajo,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: espaciado.xxl,
                vertical: espaciado.sm,
              ),
              child: Row(
                spacing: espaciado.md,
                children: [
                  Icon(Icons.save_alt_outlined, color: alertas.textoBajo),
                  Expanded(
                    child: Text(
                      '$_texto Si se daña la computadora se pierde todo.',
                      style: TextStyle(color: alertas.textoBajo),
                    ),
                  ),
                  TextButton(
                    onPressed: onRespaldar,
                    style: TextButton.styleFrom(
                      foregroundColor: alertas.textoBajo,
                    ),
                    child: Row(
                      spacing: espaciado.sm,
                      children: [
                        const Text('Respaldar ahora'),
                        TeclaAtajo('Ctrl+B', color: alertas.textoBajo),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => unawaited(respaldo.posponer()),
                    style: TextButton.styleFrom(
                      foregroundColor: alertas.textoBajo,
                    ),
                    child: const Text('Mañana'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
