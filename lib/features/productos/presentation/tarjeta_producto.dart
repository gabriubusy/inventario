import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/estilo_estado.dart';
import 'package:inventario/features/productos/presentation/etiqueta_estado.dart';

class TarjetaProducto extends StatelessWidget {
  const TarjetaProducto(this.producto, {super.key});

  static const _cifras = [FontFeature.tabularFigures()];

  final Producto producto;

  /// The bar is full at twice the minimum, so "low" sits under half.
  double get _nivel => producto.minimo <= 0
      ? 1
      : math.min(1, producto.existencia / (producto.minimo * 2));

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final estado = producto.estado;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(espaciado.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        producto.categoria.etiqueta,
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: colores.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (estado != EstadoStock.disponible) EtiquetaEstado(estado),
              ],
            ),
            const Spacer(),
            // Shrinks instead of wrapping when a large figure meets a narrow card.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                producto.unidad.formatear(producto.existencia),
                style: tema.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: _cifras,
                ),
              ),
            ),
            SizedBox(height: espaciado.xs),
            Row(
              spacing: espaciado.sm,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(espaciado.xs),
                    child: LinearProgressIndicator(
                      value: _nivel,
                      minHeight: espaciado.sm - 2,
                      color: estiloDeEstado(context, estado).barra,
                      backgroundColor: colores.surfaceContainerHighest,
                    ),
                  ),
                ),
                Text(
                  'mín. ${producto.unidad.formatear(producto.minimo)}',
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: colores.onSurfaceVariant,
                    fontFeatures: _cifras,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
