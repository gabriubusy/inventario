import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/presentation/textos_movimiento.dart';

/// Time · product and detail · amount; crossed out once cancelled.
class FilaVentaHoy extends StatelessWidget {
  const FilaVentaHoy({
    super.key,
    required this.venta,
    required this.elegida,
    required this.onElegir,
    required this.onAnular,
  });

  static const _alto = 60.0;
  static const _anchoHora = 52.0;
  static const _anchoImporte = 96.0;
  static const _anchoAccion = 110.0;

  final Movimiento venta;
  final bool elegida;
  final VoidCallback onElegir;
  final VoidCallback onAnular;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final alertas = context.coloresEstado;
    final espaciado = context.espaciado;
    const cifras = [FontFeature.tabularFigures()];
    final tachado = venta.anulada
        ? TextDecoration.lineThrough
        : TextDecoration.none;
    final suave = tema.textTheme.bodySmall?.copyWith(
      color: colores.onSurfaceVariant,
      fontFeatures: cifras,
    );
    final fuerte = tema.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
      decoration: tachado,
      color: venta.anulada ? colores.onSurfaceVariant : null,
      fontFeatures: cifras,
    );
    final importe = venta.importe;
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
                  SizedBox(
                    width: _anchoHora,
                    child: Text(textoHora(venta.fecha), style: suave),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(venta.producto, style: fuerte),
                        Text(textoDetalleMovimiento(venta), style: suave),
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
                  SizedBox(
                    width: _anchoAccion,
                    child: venta.anulada
                        ? Text(
                            'Anulada',
                            textAlign: TextAlign.right,
                            style: tema.textTheme.labelLarge?.copyWith(
                              color: alertas.textoAgotado,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : elegida
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: onAnular,
                              style: TextButton.styleFrom(
                                foregroundColor: alertas.textoAgotado,
                              ),
                              child: const Text('Anular · Supr'),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
