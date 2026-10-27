import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/compras/domain/cuenta_por_pagar.dart';

/// Widths shared by the header and every row of the payables table.
class ColumnasCuenta extends StatelessWidget {
  const ColumnasCuenta({super.key, required this.celdas});

  static const _flex = [4, 2, 2, 2, 2, 2, 3];

  /// Supplier, invoice, date, total, paid, owed, due.
  final List<Widget> celdas;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.espaciado.md,
      children: [
        for (final (i, celda) in celdas.indexed)
          Expanded(flex: _flex[i], child: celda),
      ],
    );
  }
}

class FilaCuenta extends StatelessWidget {
  const FilaCuenta({
    super.key,
    required this.cuenta,
    required this.hoy,
    required this.elegida,
    required this.onElegir,
  });

  final CuentaPorPagar cuenta;
  final DateTime hoy;
  final bool elegida;
  final VoidCallback onElegir;

  String get _vence {
    final dias = cuenta.diasParaVencer(hoy);
    return switch (cuenta.estado(hoy)) {
      EstadoCuenta.pagada => 'Pagada',
      EstadoCuenta.vencida => 'Vencida · ${-dias} d',
      _ when dias == 0 => 'Vence hoy',
      _ => 'En $dias d · ${formatearFechaCorta(cuenta.compra.vence!, hoy)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final alertas = context.coloresEstado;
    final espaciado = context.espaciado;
    final compra = cuenta.compra;
    final estado = cuenta.estado(hoy);
    const cifras = [FontFeature.tabularFigures()];
    final base = tema.textTheme.bodyMedium?.copyWith(fontFeatures: cifras);
    final (fondo, tinta) = switch (estado) {
      EstadoCuenta.vencida => (alertas.fondoAgotado, alertas.textoAgotado),
      EstadoCuenta.porVencer => (alertas.fondoBajo, alertas.textoBajo),
      _ => (colores.surfaceContainerHighest, colores.onSurfaceVariant),
    };
    return Semantics(
      selected: elegida,
      button: true,
      child: InkWell(
        onTap: onElegir,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: elegida ? colores.primary.withValues(alpha: 0.06) : null,
            border: Border(
              top: BorderSide(color: colores.outlineVariant),
              left: BorderSide(
                color: elegida ? colores.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: espaciado.md,
              vertical: espaciado.md,
            ),
            child: ColumnasCuenta(
              celdas: [
                Text(
                  compra.proveedor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: base?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  compra.factura.isEmpty ? '—' : compra.factura,
                  style: base,
                ),
                Text(
                  formatearFechaCorta(compra.fecha, hoy),
                  style: base?.copyWith(color: colores.onSurfaceVariant),
                ),
                Text(
                  formatearDolares(compra.total),
                  textAlign: TextAlign.right,
                  style: base,
                ),
                Text(
                  cuenta.abonado == 0 ? '—' : formatearDolares(cuenta.abonado),
                  textAlign: TextAlign.right,
                  style: base?.copyWith(color: colores.onSurfaceVariant),
                ),
                Text(
                  formatearDolares(cuenta.debe < 0 ? 0 : cuenta.debe),
                  textAlign: TextAlign.right,
                  style: base?.copyWith(fontWeight: FontWeight.w600),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: fondo,
                      borderRadius: BorderRadius.circular(espaciado.xxl),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: espaciado.sm,
                        vertical: espaciado.xs / 2,
                      ),
                      child: Text(
                        _vence,
                        style: tema.textTheme.labelSmall?.copyWith(
                          color: tinta,
                          fontWeight: FontWeight.w600,
                          fontFeatures: cifras,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
