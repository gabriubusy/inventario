import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';

/// One line: "3 productos" on the left, the total and its bolívares at
/// today's rate on the right.
class TotalCompra extends StatelessWidget {
  const TotalCompra({super.key, required this.lineas, this.aBolivares});

  final List<LineaCompra> lineas;
  final int? Function(int)? aBolivares;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final total = lineas.fold(0, (suma, l) => suma + l.subtotal);
    final bolivares = aBolivares?.call(total);
    const cifras = [FontFeature.tabularFigures()];
    final suave = tema.textTheme.bodyMedium?.copyWith(
      color: colores.onSurfaceVariant,
      fontFeatures: cifras,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surfaceContainerLowest,
        border: Border.all(color: colores.outlineVariant),
        borderRadius: BorderRadius.circular(espaciado.sm + 2),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.lg,
          vertical: espaciado.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: espaciado.md,
          children: [
            Expanded(
              child: Text(
                lineas.length == 1
                    ? '1 producto · Total'
                    : '${lineas.length} productos · Total',
                style: suave,
              ),
            ),
            if (bolivares != null && total > 0)
              Text(
                '${formatearBolivares(bolivares)} a tasa de hoy',
                style: suave,
              ),
            Text(
              formatearDolares(total),
              style: tema.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: cifras,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
