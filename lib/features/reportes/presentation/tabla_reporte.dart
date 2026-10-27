import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/reportes/domain/reporte.dart';

/// The report's table; numeric columns align right, the first stands out.
class TablaReporte extends StatelessWidget {
  const TablaReporte({super.key, required this.reporte});

  final Reporte reporte;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    const cifras = [FontFeature.tabularFigures()];
    Widget fila(List<String> celdas, {required bool encabezado}) => Padding(
      padding: EdgeInsets.symmetric(
        horizontal: espaciado.lg,
        vertical: encabezado ? espaciado.md : espaciado.sm + 2,
      ),
      child: Row(
        spacing: espaciado.md,
        children: [
          for (final (i, celda) in celdas.indexed)
            Expanded(
              flex: i == 0 ? 3 : 2,
              child: Text(
                encabezado ? celda.toUpperCase() : celda,
                textAlign: reporte.numericas.contains(i)
                    ? TextAlign.right
                    : TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: encabezado
                    ? tema.textTheme.labelSmall?.copyWith(
                        color: colores.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      )
                    : tema.textTheme.bodyMedium?.copyWith(
                        fontWeight: i == 0 ? FontWeight.w600 : null,
                        fontFeatures: cifras,
                      ),
              ),
            ),
        ],
      ),
    );
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          fila(reporte.columnas, encabezado: true),
          if (reporte.filas.isEmpty)
            Padding(
              padding: EdgeInsets.all(espaciado.xl),
              child: Text(
                'Sin datos en este periodo',
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: colores.onSurfaceVariant,
                ),
              ),
            ),
          for (final celdas in reporte.filas) ...[
            Divider(height: 1, color: colores.outlineVariant),
            fila(celdas, encabezado: false),
          ],
        ],
      ),
    );
  }
}
