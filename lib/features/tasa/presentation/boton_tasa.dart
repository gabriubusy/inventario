import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';

/// "Tasa de hoy 1 $ = 40,00 Bs  Ctrl+T", always in sight while pricing.
class BotonTasa extends StatelessWidget {
  const BotonTasa({
    super.key,
    required this.controlador,
    required this.onPulsar,
  });

  final ControladorTasa controlador;
  final VoidCallback onPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final tasa = controlador.tasa;
    return OutlinedButton(
      onPressed: onPulsar,
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.espaciado.sm,
        children: [
          if (tasa == null)
            const Text('Poner tasa')
          else ...[
            Text(
              controlador.esDeHoy ? 'Tasa de hoy' : 'Última tasa',
              style: TextStyle(color: colores.onSurfaceVariant),
            ),
            Text(
              '1 \$ = ${formatearBolivares(tasa.bolivaresPorDolar)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
          TeclaAtajo('Ctrl+T', color: colores.onSurfaceVariant),
        ],
      ),
    );
  }
}
