import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/etiqueta_estado.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// Compact: name, what there is and how it splits by brand. Restocking
/// lives in "Hay que reponer", so no bar or minimum here.
class TarjetaProducto extends StatelessWidget {
  const TarjetaProducto(this.producto, {super.key});

  static const _cifras = [FontFeature.tabularFigures()];

  final Producto producto;

  /// "+1 abierta · 19,2 kg" next to the pieces; null for other products.
  String? get _junto {
    if (!producto.forma.cuentaPiezas) return null;
    final abiertas = producto.piezasAbiertas;
    final peso = producto.forma.unidad.formatear(producto.cantidad);
    return abiertas > 0 ? '+$abiertas abierta · $peso' : peso;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final estado = producto.estado;
    final suave = tema.textTheme.bodySmall?.copyWith(
      color: colores.onSurfaceVariant,
      fontFeatures: _cifras,
    );
    final junto = _junto;
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.lg,
          vertical: espaciado.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: espaciado.sm,
              children: [
                Expanded(
                  child: Text(
                    producto.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (estado != EstadoStock.disponible) EtiquetaEstado(estado),
              ],
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: textoPrincipal(producto),
                    style: tema.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (junto != null) TextSpan(text: '  $junto', style: suave),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFeatures: _cifras),
            ),
            Text(
              textoMarcas(producto) ?? 'Sin marcas con existencia',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: suave,
            ),
          ],
        ),
      ),
    );
  }
}
