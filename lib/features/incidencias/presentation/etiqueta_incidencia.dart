import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/presentation/textos_incidencia.dart';

/// Amber pill while open, red once overdue; plain text when answered.
class EtiquetaIncidencia extends StatelessWidget {
  const EtiquetaIncidencia({
    super.key,
    required this.incidencia,
    required this.hoy,
  });

  final Incidencia incidencia;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final texto = textoEstado(incidencia, hoy);
    if (!incidencia.abierta) {
      return Text(
        texto,
        style: tema.textTheme.bodySmall?.copyWith(
          color: tema.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final colores = context.coloresEstado;
    final atrasada = incidencia.atrasada(hoy);
    final espaciado = context.espaciado;
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: atrasada ? colores.fondoAgotado : colores.fondoBajo,
          borderRadius: BorderRadius.circular(espaciado.xxl),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: espaciado.sm + 2,
            vertical: espaciado.xs / 2,
          ),
          child: Text(
            texto,
            style: tema.textTheme.labelSmall?.copyWith(
              color: atrasada ? colores.textoAgotado : colores.textoBajo,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
