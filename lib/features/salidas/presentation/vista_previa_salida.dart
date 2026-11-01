import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/etiqueta_estado.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/salidas/domain/modo_venta.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/domain/vender.dart';
import 'package:inventario/features/salidas/presentation/selector_modo_venta.dart';

/// Before saving: whether a piece gets opened, how the brand is left and
/// whether the product falls below its minimum. Only warns, never blocks.
class VistaPreviaSalida extends StatelessWidget {
  const VistaPreviaSalida({
    super.key,
    required this.producto,
    required this.salida,
  });

  final Producto producto;
  final Salida salida;

  @override
  Widget build(BuildContext context) {
    final despues = vender(producto, salida);
    final indice = indiceLoteDeSalida(producto, salida);
    if (despues == null || indice == -1) return const SizedBox.shrink();
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final alertas = context.coloresEstado;
    final espaciado = context.espaciado;
    final antes = producto.lotes[indice];
    const cifras = [FontFeature.tabularFigures()];
    // A whole piece going out was easy to miss when only a cut was meant.
    final aviso = switch (salida.modo) {
      ModoVenta.piezaEntera =>
        'Se va 1 pieza entera de '
            '${producto.forma.unidad.formatear(salida.cantidad)}. '
            '¿Solo un trozo? Por kilo · ${teclasModoVenta[ModoVenta.porPeso]!.$2}',
      _ when abrePieza(antes, salida.modo) =>
        '${antes.marca} no tiene pieza abierta: esta venta abre 1 pieza.',
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: espaciado.sm,
      children: [
        if (aviso != null)
          DecoratedBox(
            decoration: BoxDecoration(
              color: alertas.fondoBajo,
              borderRadius: BorderRadius.circular(espaciado.sm + 2),
            ),
            child: Padding(
              padding: EdgeInsets.all(espaciado.md),
              child: Text(aviso, style: TextStyle(color: alertas.textoBajo)),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colores.surfaceContainerLowest,
            border: Border.all(color: colores.outlineVariant),
            borderRadius: BorderRadius.circular(espaciado.sm + 2),
          ),
          child: Padding(
            padding: EdgeInsets.all(espaciado.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: espaciado.xs,
              children: [
                Text(
                  '${antes.marca} quedará: ${textoLote(producto, antes)} → '
                  '${textoLote(despues, despues.lotes[indice])}',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: cifras,
                  ),
                ),
                if (producto.presentaciones.isNotEmpty)
                  Text(
                    'Total: ${textoStock(producto)} → ${textoStock(despues)}',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: colores.onSurfaceVariant,
                      fontFeatures: cifras,
                    ),
                  ),
                if (despues.estado != EstadoStock.disponible &&
                    despues.estado != producto.estado)
                  Row(
                    spacing: espaciado.sm,
                    children: [
                      EtiquetaEstado(despues.estado),
                      Expanded(
                        child: Text(
                          'Quedará ${textoPrincipal(despues)}; '
                          '${textoMinimo(despues)}.',
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: colores.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
