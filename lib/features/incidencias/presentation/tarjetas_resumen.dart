import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/incidencias/domain/resumen_incidencias.dart';

/// Open incidents, this month's, and the supplier with most this month.
class TarjetasResumen extends StatelessWidget {
  const TarjetasResumen({super.key, required this.resumen});

  final ResumenIncidencias resumen;

  @override
  Widget build(BuildContext context) {
    final proveedor = resumen.proveedorConMas;
    return Row(
      spacing: context.espaciado.lg,
      children: [
        Expanded(
          child: _Tarjeta(
            titulo: 'Abiertas',
            valor: '${resumen.abiertas}',
            color: resumen.abiertas > 0
                ? context.coloresEstado.textoBajo
                : null,
          ),
        ),
        Expanded(
          child: _Tarjeta(titulo: 'Este mes', valor: '${resumen.delMes}'),
        ),
        Expanded(
          child: _Tarjeta(
            titulo: 'Más incidencias este mes',
            valor: proveedor == null
                ? '—'
                : '$proveedor · ${resumen.deEseProveedor}',
          ),
        ),
      ],
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.titulo, required this.valor, this.color});

  final String titulo;
  final String valor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.espaciado.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.espaciado.xs,
          children: [
            Text(
              titulo,
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
