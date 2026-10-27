import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/presentation/columnas_incidencia.dart';
import 'package:inventario/features/incidencias/presentation/etiqueta_incidencia.dart';
import 'package:inventario/features/incidencias/presentation/textos_incidencia.dart';

class FilaIncidencia extends StatelessWidget {
  const FilaIncidencia({
    super.key,
    required this.incidencia,
    required this.hoy,
    required this.elegida,
    required this.mostrarProveedor,
    required this.onElegir,
  });

  final Incidencia incidencia;
  final DateTime hoy;
  final bool elegida;
  final bool mostrarProveedor;
  final VoidCallback onElegir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    // Answered incidents step back so the open ones stand out.
    final base = tema.textTheme.bodyMedium?.copyWith(
      color: incidencia.abierta ? null : colores.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final fuerte = base?.copyWith(
      fontWeight: incidencia.abierta ? FontWeight.w600 : null,
    );
    return Semantics(
      selected: elegida,
      button: true,
      child: InkWell(
        onTap: onElegir,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: elegida ? colores.primary.withValues(alpha: 0.06) : null,
            border: Border(
              top: BorderSide(color: colores.outlineVariant),
              left: BorderSide(
                color: elegida ? colores.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: espaciado.md,
              vertical: espaciado.md,
            ),
            child: ColumnasIncidencia(
              mostrarProveedor: mostrarProveedor,
              fecha: Text(
                formatearFechaCorta(incidencia.fecha, hoy),
                style: base,
              ),
              proveedor: Text(
                incidencia.proveedor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: fuerte,
              ),
              producto: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: incidencia.producto,
                      style: mostrarProveedor ? null : fuerte,
                    ),
                    TextSpan(text: ' · ${incidencia.marca}'),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: base,
              ),
              tipo: Text(
                incidencia.tipo.etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: base,
              ),
              afectado: Text(
                textoAfectado(incidencia),
                textAlign: TextAlign.right,
                style: base,
              ),
              estado: EtiquetaIncidencia(incidencia: incidencia, hoy: hoy),
            ),
          ),
        ),
      ),
    );
  }
}
