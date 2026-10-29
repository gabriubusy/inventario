import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/compras/domain/cuenta_por_pagar.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/compensacion.dart';
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';

/// Alt+Q, W, E pick each way of making up, in declaration order.
const teclasCompensacion = [
  LogicalKeyboardKey.keyQ,
  LogicalKeyboardKey.keyW,
  LogicalKeyboardKey.keyE,
];
const _letrasCompensacion = ['Q', 'W', 'E'];
const _letrasMedio = ['A', 'S', 'D', 'F', 'G'];

/// Discount on an invoice (Alt+T picks another), money back with how it came
/// (Alt+A–G), or the goods again.
class SeccionCompensacion extends StatelessWidget {
  const SeccionCompensacion({
    super.key,
    required this.compensacion,
    required this.cuentas,
    required this.compraId,
    required this.medio,
    required this.total,
    required this.hoy,
    required this.onCompensacion,
    required this.onCompra,
    required this.onMedio,
  });

  final Compensacion compensacion;

  /// The supplier's invoices still owed, oldest first.
  final List<CuentaPorPagar> cuentas;
  final String? compraId;
  final MedioPago medio;

  /// What goes back, in dollar hundredths.
  final int total;
  final DateTime hoy;
  final ValueChanged<Compensacion> onCompensacion;
  final ValueChanged<String> onCompra;
  final ValueChanged<MedioPago> onMedio;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final suave = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: espaciado.md,
      children: [
        ExcludeFocus(
          child: Row(
            spacing: espaciado.sm,
            children: [
              for (final (i, c) in Compensacion.values.indexed)
                Expanded(
                  child: OpcionSeleccionable(
                    titulo: c.etiqueta,
                    detalle: '${c.detalle} · Alt+${_letrasCompensacion[i]}',
                    elegida: c == compensacion,
                    onPulsar: () => onCompensacion(c),
                  ),
                ),
            ],
          ),
        ),
        switch (compensacion) {
          Compensacion.descuento => _Facturas(
            cuentas: cuentas,
            compraId: compraId,
            total: total,
            hoy: hoy,
            onCompra: onCompra,
          ),
          Compensacion.dinero => ExcludeFocus(
            child: Wrap(
              spacing: espaciado.sm,
              runSpacing: espaciado.sm,
              children: [
                for (final (i, m) in MedioPago.paraProveedores.indexed)
                  ChoiceChip(
                    label: Text('${m.etiqueta} · Alt+${_letrasMedio[i]}'),
                    selected: m == medio,
                    showCheckmark: false,
                    onSelected: (_) => onMedio(m),
                  ),
              ],
            ),
          ),
          Compensacion.repone => Text(
            'Queda pendiente hasta que lo traiga; se marca en la lista de '
            'devoluciones (F6, Alt+D).',
            style: suave,
          ),
        },
      ],
    );
  }
}

class _Facturas extends StatelessWidget {
  const _Facturas({
    required this.cuentas,
    required this.compraId,
    required this.total,
    required this.hoy,
    required this.onCompra,
  });

  final List<CuentaPorPagar> cuentas;
  final String? compraId;
  final int total;
  final DateTime hoy;
  final ValueChanged<String> onCompra;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final suave = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    if (cuentas.isEmpty) {
      return Text(
        'No se le debe ninguna factura a crédito: elige otra forma.',
        style: tema.textTheme.bodyMedium?.copyWith(
          color: tema.colorScheme.error,
        ),
      );
    }
    final elegida = cuentas.where((c) => c.compra.id == compraId).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: espaciado.sm,
      children: [
        ExcludeFocus(
          child: Wrap(
            spacing: espaciado.sm,
            runSpacing: espaciado.sm,
            children: [
              for (final c in cuentas)
                ChoiceChip(
                  label: Text(
                    [
                      if (c.compra.factura.isNotEmpty)
                        'Factura ${c.compra.factura}'
                      else
                        'Sin número',
                      formatearFechaCorta(c.compra.fecha, hoy),
                      'debe ${formatearDolares(c.debe)}',
                    ].join(' · '),
                  ),
                  selected: c == elegida,
                  showCheckmark: false,
                  onSelected: (_) => onCompra(c.compra.id),
                ),
            ],
          ),
        ),
        if (elegida != null)
          Text(
            'Debe ${formatearDolares(elegida.debe)} → '
            '${formatearDolares(elegida.debe - total)}'
            '${cuentas.length > 1 ? ' · Alt+T otra factura' : ''}',
            style: suave,
          ),
      ],
    );
  }
}
