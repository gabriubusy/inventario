import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/presentation/textos_movimiento.dart';

/// Today's latest sales: time, product, brand and amount. Cancelled ones
/// stay, crossed out; F7 opens them all to cancel one.
class UltimasVentas extends StatelessWidget {
  const UltimasVentas({
    super.key,
    required this.ventas,
    required this.onVerTodas,
  });

  static const _anchoHora = 48.0;
  static const _anchoImporte = 90.0;

  final List<Movimiento> ventas;
  final VoidCallback onVerTodas;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    const cifras = [FontFeature.tabularFigures()];
    final suave = tema.textTheme.bodyMedium?.copyWith(
      color: colores.onSurfaceVariant,
      fontFeatures: cifras,
    );
    final fuerte = tema.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontFeatures: cifras,
    );
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(espaciado.lg),
            child: Row(
              spacing: espaciado.sm,
              children: [
                Expanded(
                  child: Text(
                    'Últimas ventas',
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text('Vender', style: suave),
                TeclaAtajo('F1', color: colores.onSurfaceVariant),
                // Compact, so the card keeps the height of a plain title row.
                TextButton(
                  onPressed: onVerTodas,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.symmetric(horizontal: espaciado.sm),
                    minimumSize: Size.zero,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: espaciado.sm,
                    children: [
                      const Text('Ver y anular'),
                      TeclaAtajo('F7', color: colores.onSurfaceVariant),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (ventas.isEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                espaciado.lg,
                0,
                espaciado.lg,
                espaciado.lg,
              ),
              child: Text(
                'Aún no hay ventas hoy. Registra una con F1.',
                style: suave,
              ),
            ),
          for (final venta in ventas)
            _FilaVenta(
              venta: venta,
              suave: suave,
              fuerte: venta.anulada
                  ? fuerte?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: colores.onSurfaceVariant,
                    )
                  : fuerte,
            ),
        ],
      ),
    );
  }
}

class _FilaVenta extends StatelessWidget {
  const _FilaVenta({
    required this.venta,
    required this.suave,
    required this.fuerte,
  });

  final Movimiento venta;
  final TextStyle? suave;
  final TextStyle? fuerte;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final espaciado = context.espaciado;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colores.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.lg,
          vertical: espaciado.sm + 2,
        ),
        child: Row(
          spacing: espaciado.md,
          children: [
            SizedBox(
              width: UltimasVentas._anchoHora,
              child: Text(textoHora(venta.fecha), style: suave),
            ),
            Expanded(
              flex: 3,
              child: Text(
                venta.producto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: fuerte,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                textoDetalleMovimiento(venta),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: suave,
              ),
            ),
            SizedBox(
              width: UltimasVentas._anchoImporte,
              child: Text(
                venta.importe == null ? '—' : formatearDolares(venta.importe!),
                textAlign: TextAlign.right,
                style: fuerte,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
