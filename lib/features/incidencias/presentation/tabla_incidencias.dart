import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/presentation/columnas_incidencia.dart';
import 'package:inventario/features/incidencias/presentation/fila_incidencia.dart';

class TablaIncidencias extends StatelessWidget {
  const TablaIncidencias({
    super.key,
    required this.incidencias,
    required this.hoy,
    required this.elegidaId,
    required this.onElegir,
    this.mostrarProveedor = true,
  });

  final List<Incidencia> incidencias;
  final DateTime hoy;
  final String? elegidaId;
  final ValueChanged<Incidencia> onElegir;
  final bool mostrarProveedor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final encabezado = tema.textTheme.labelSmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          // Same inset as the rows, whose left border takes 3 px.
          padding: EdgeInsets.fromLTRB(
            espaciado.md + 3,
            0,
            espaciado.md,
            espaciado.sm,
          ),
          child: ColumnasIncidencia(
            mostrarProveedor: mostrarProveedor,
            fecha: Text('FECHA', style: encabezado),
            proveedor: Text('PROVEEDOR', style: encabezado),
            producto: Text('PRODUCTO · MARCA', style: encabezado),
            tipo: Text('QUÉ PASÓ', style: encabezado),
            afectado: Text(
              'AFECTADO',
              textAlign: TextAlign.right,
              style: encabezado,
            ),
            estado: Text('ESTADO', style: encabezado),
          ),
        ),
        for (final incidencia in incidencias)
          FilaIncidencia(
            incidencia: incidencia,
            hoy: hoy,
            elegida: incidencia.id == elegidaId,
            mostrarProveedor: mostrarProveedor,
            onElegir: () => onElegir(incidencia),
          ),
      ],
    );
  }
}
