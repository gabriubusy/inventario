import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/estilo_estado.dart';
import 'package:inventario/features/productos/presentation/etiqueta_estado.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

class TarjetaProducto extends StatelessWidget {
  const TarjetaProducto(this.producto, {super.key});

  static const _cifras = [FontFeature.tabularFigures()];

  final Producto producto;

  /// The bar is full at twice the minimum, so "low" sits under half.
  double get _nivel => producto.minimo <= 0
      ? 1
      : math.min(1, producto.medida / (producto.minimo * 2));

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final estado = producto.estado;
    final secundario = tema.textTheme.bodySmall?.copyWith(
      color: colores.onSurfaceVariant,
      fontFeatures: _cifras,
    );
    final peso = textoPeso(producto);
    final marcas = textoMarcas(producto);
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
                      Text(producto.categoria.etiqueta, style: secundario),
                    ],
                  ),
                ),
                if (estado != EstadoStock.disponible) EtiquetaEstado(estado),
              ],
            ),
            const Spacer(),
            _CifraPrincipal(producto),
            if (peso != null)
              Text(
                peso,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.bodySmall?.copyWith(
                  fontFeatures: _cifras,
                ),
              ),
            if (marcas != null)
              Text(
                marcas,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: secundario,
              ),
            SizedBox(height: espaciado.sm),
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
                Text(textoMinimo(producto), style: secundario),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Main figure plus a "+1 abierta" chip; shrinks instead of wrapping.
class _CifraPrincipal extends StatelessWidget {
  const _CifraPrincipal(this.producto);

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final abiertas = producto.piezasAbiertas;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        spacing: espaciado.sm,
        children: [
          Text(
            textoPrincipal(producto),
            style: tema.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: TarjetaProducto._cifras,
            ),
          ),
          if (abiertas > 0)
            DecoratedBox(
              decoration: BoxDecoration(
                color: tema.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(espaciado.xxl),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: espaciado.sm,
                  vertical: espaciado.xs / 2,
                ),
                child: Text(
                  abiertas == 1 ? '+1 abierta' : '+$abiertas abiertas',
                  style: tema.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
