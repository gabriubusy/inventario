import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';

/// Warns that bolívares use an old rate, or none, until today's is entered.
class AvisoTasa extends StatelessWidget {
  const AvisoTasa({
    super.key,
    required this.controlador,
    required this.onPoner,
  });

  final ControladorTasa controlador;
  final VoidCallback onPoner;

  String get _texto {
    final tasa = controlador.tasa;
    if (tasa == null) {
      return 'Pon la tasa de hoy para ver los precios en bolívares.';
    }
    return 'Pon la tasa de hoy. Mientras, se usa la del '
        '${formatearFechaLarga(tasa.fecha).toLowerCase()}: '
        '1 \$ = ${formatearBolivares(tasa.bolivaresPorDolar)}.';
  }

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.info_outline, color: alertas.textoBajo),
              Expanded(
                child: Text(_texto, style: TextStyle(color: alertas.textoBajo)),
              ),
              TextButton(
                onPressed: onPoner,
                style: TextButton.styleFrom(foregroundColor: alertas.textoBajo),
                child: Row(
                  spacing: espaciado.sm,
                  children: [
                    const Text('Poner tasa'),
                    TeclaAtajo('Ctrl+T', color: alertas.textoBajo),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
