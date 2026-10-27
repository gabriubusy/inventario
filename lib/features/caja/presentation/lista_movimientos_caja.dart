import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/textos_dinero.dart';
import 'package:inventario/features/caja/domain/movimiento_caja.dart';
import 'package:inventario/features/movimientos/presentation/textos_movimiento.dart';

/// Every money movement of the till, newest first.
class ListaMovimientosCaja extends StatelessWidget {
  const ListaMovimientosCaja({super.key, required this.movimientos});

  static const _anchoHora = 52.0;
  static const _anchoTipo = 96.0;

  final List<MovimientoCaja> movimientos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final alertas = context.coloresEstado;
    final espaciado = context.espaciado;
    const cifras = [FontFeature.tabularFigures()];
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(espaciado.lg),
            child: Text(
              'Movimientos de la caja',
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          for (final m in movimientos)
            DecoratedBox(
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
                      width: _anchoHora,
                      child: Text(
                        textoHora(m.fecha),
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: colores.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: _anchoTipo,
                      child: Text(
                        m.tipo.etiqueta.toUpperCase(),
                        style: tema.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: switch (m.tipo) {
                            TipoMovimientoCaja.venta ||
                            TipoMovimientoCaja.ingreso => colores.primary,
                            TipoMovimientoCaja.apertura => colores.tertiary,
                            _ => alertas.textoBajo,
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        m.detalle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      [
                        for (final MapEntry(key: medio, value: monto)
                            in m.montos.entries)
                          '${medio.etiqueta} ${textoConSigno(monto, medio.moneda)}',
                      ].join(' · '),
                      style: tema.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: cifras,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
