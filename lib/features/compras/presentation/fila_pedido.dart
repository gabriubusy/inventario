import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/seguir_elegido.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/estado_pedido.dart';

/// Widths shared by the header and every row of the orders table.
class ColumnasPedido extends StatelessWidget {
  const ColumnasPedido({super.key, required this.celdas});

  static const _flex = [2, 4, 3, 2, 3, 3, 4];

  /// Date, supplier, invoice, lines, total, how it is paid, state.
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

class FilaPedido extends StatelessWidget {
  const FilaPedido({
    super.key,
    required this.compra,
    required this.hoy,
    required this.elegida,
    required this.onElegir,
    required this.onRecibir,
  });

  final Compra compra;
  final DateTime hoy;
  final bool elegida;
  final VoidCallback onElegir;

  /// Double click goes straight to confirming what arrived.
  final VoidCallback onRecibir;

  String get _pago {
    final vence = compra.vence;
    if (vence == null) return 'Contado · ${compra.medio?.etiqueta ?? ''}';
    return 'Crédito ${formatearFechaCorta(vence, hoy)}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    const cifras = [FontFeature.tabularFigures()];
    final base = tema.textTheme.bodyMedium?.copyWith(fontFeatures: cifras);
    final suave = base?.copyWith(color: colores.onSurfaceVariant);
    final lineas = compra.lineas.length;
    return SeguirElegido(
      elegido: elegida,
      child: Semantics(
        selected: elegida,
        button: true,
        child: InkWell(
          onTap: onElegir,
          onDoubleTap: onRecibir,
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
              padding: EdgeInsets.all(espaciado.md),
              child: ColumnasPedido(
                celdas: [
                  Text(formatearFechaCorta(compra.fecha, hoy), style: suave),
                  Text(
                    compra.proveedor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: base?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    compra.factura.isEmpty ? 'sin factura' : compra.factura,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: suave,
                  ),
                  Text('$lineas', textAlign: TextAlign.right, style: base),
                  Text(
                    formatearDolares(compra.total),
                    textAlign: TextAlign.right,
                    style: base?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _pago,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: suave,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ChipEstadoPedido(compra: compra),
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

/// "Pendiente", "Parcial · faltan 2" or "Recibido con diferencias".
class ChipEstadoPedido extends StatelessWidget {
  const ChipEstadoPedido({super.key, required this.compra});

  final Compra compra;

  String get _texto {
    final estado = compra.estado;
    if (estado != EstadoPedido.parcial) return estado.etiqueta;
    final faltan = compra.lineas.where((l) => !l.recibida).length;
    return 'Parcial · ${faltan == 1 ? 'falta 1' : 'faltan $faltan'}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final alertas = context.coloresEstado;
    final espaciado = context.espaciado;
    final (fondo, tinta) = switch (compra.estado) {
      EstadoPedido.pendiente ||
      EstadoPedido.conDiferencias => (alertas.fondoBajo, alertas.textoBajo),
      EstadoPedido.parcial => (
        colores.primary.withValues(alpha: 0.10),
        colores.primary,
      ),
      EstadoPedido.recibido => (alertas.fondoBien, alertas.textoBien),
    };
    return DecoratedBox(
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
          _texto,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tema.textTheme.labelSmall?.copyWith(
            color: tinta,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
