import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// The invoice lines added so far, each with its subtotal and a way out.
class TablaLineasCompra extends StatelessWidget {
  const TablaLineasCompra({
    super.key,
    required this.lineas,
    required this.onQuitar,
  });

  final List<LineaCompra> lineas;
  final ValueChanged<int> onQuitar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    const cifras = [FontFeature.tabularFigures()];
    final suave = tema.textTheme.bodySmall?.copyWith(
      color: colores.onSurfaceVariant,
      fontFeatures: cifras,
    );
    if (lineas.isEmpty) {
      return Text(
        'Aún no hay productos en la factura.',
        style: tema.textTheme.bodyMedium?.copyWith(
          color: colores.onSurfaceVariant,
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colores.outlineVariant),
        borderRadius: BorderRadius.circular(espaciado.sm + 2),
      ),
      child: Column(
        children: [
          for (final (i, linea) in lineas.indexed)
            Container(
              decoration: BoxDecoration(
                border: i == 0
                    ? null
                    : Border(top: BorderSide(color: colores.outlineVariant)),
              ),
              padding: EdgeInsets.only(left: espaciado.md),
              child: Row(
                spacing: espaciado.md,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          linea.producto,
                          style: tema.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(linea.marca, style: suave),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      [
                        if (linea.piezas > 0) textoPiezas(linea.piezas),
                        linea.forma.unidad.formatear(linea.cantidad),
                      ].join(' · '),
                      textAlign: TextAlign.right,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        fontFeatures: cifras,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${formatearDolares(linea.costo)} '
                      '/${linea.forma.unidad.simbolo}',
                      textAlign: TextAlign.right,
                      style: suave,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      formatearDolares(linea.subtotal),
                      textAlign: TextAlign.right,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: cifras,
                      ),
                    ),
                  ),
                  ExcludeFocus(
                    child: IconButton(
                      tooltip: 'Quitar',
                      icon: const Icon(Icons.close),
                      onPressed: () => onQuitar(i),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
