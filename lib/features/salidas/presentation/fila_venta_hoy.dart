import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/presentation/textos_movimiento.dart';

/// Product and detail · amount, with Devolver and Anular when chosen;
/// crossed out once cancelled.
class FilaVentaHoy extends StatelessWidget {
  const FilaVentaHoy({
    super.key,
    required this.venta,
    required this.elegida,
    required this.onElegir,
    this.devuelto = 0,
    this.onDevolver,
    this.onAnular,
  });

  static const _alto = 60.0;
  static const _anchoImporte = 96.0;

  final Movimiento venta;
  final bool elegida;
  final VoidCallback onElegir;

  /// Already brought back, scaled like the sale's quantity.
  final int devuelto;

  /// Null when nothing more can come back.
  final VoidCallback? onDevolver;

  /// Null where cancelling is not offered (other days).
  final VoidCallback? onAnular;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final alertas = context.coloresEstado;
    final espaciado = context.espaciado;
    const cifras = [FontFeature.tabularFigures()];
    final suave = tema.textTheme.bodySmall?.copyWith(
      color: colores.onSurfaceVariant,
      fontFeatures: cifras,
    );
    final fuerte = tema.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
      decoration: venta.anulada ? TextDecoration.lineThrough : null,
      color: venta.anulada ? colores.onSurfaceVariant : null,
      fontFeatures: cifras,
    );
    final importe = venta.importe;
    final detalle = [
      textoDetalleMovimiento(venta),
      if (devuelto > 0) 'devuelto ${venta.forma.unidad.formatear(devuelto)}',
    ].join(' · ');
    final onDevolver = this.onDevolver;
    final onAnular = this.onAnular;
    return Semantics(
      selected: elegida,
      button: true,
      child: InkWell(
        onTap: onElegir,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: elegida ? colores.primary.withValues(alpha: 0.08) : null,
            border: Border(top: BorderSide(color: colores.outlineVariant)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _alto),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: espaciado.md),
              child: Row(
                spacing: espaciado.md,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(venta.producto, style: fuerte),
                        Text(detalle, style: suave),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: _anchoImporte,
                    child: Text(
                      importe == null ? '—' : formatearDolares(importe),
                      textAlign: TextAlign.right,
                      style: fuerte,
                    ),
                  ),
                  if (venta.anulada)
                    Text(
                      'Anulada',
                      style: tema.textTheme.labelLarge?.copyWith(
                        color: alertas.textoAgotado,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else if (elegida) ...[
                    if (onDevolver != null)
                      TextButton(
                        onPressed: onDevolver,
                        child: const Text('Devolver · Alt+D'),
                      ),
                    if (onAnular != null)
                      TextButton(
                        onPressed: onAnular,
                        style: TextButton.styleFrom(
                          foregroundColor: alertas.textoAgotado,
                        ),
                        child: const Text('Anular · Supr'),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
