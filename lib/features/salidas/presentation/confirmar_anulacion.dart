import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/presentation/textos_movimiento.dart';

/// Asks before cancelling: the one confirmation the app keeps, since the
/// spec wants it for this. Enter cancels the sale, Esc keeps it.
Future<bool> confirmarAnulacion(
  BuildContext context, {
  required Movimiento venta,
  required String? quedara,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmarAnulacion(venta: venta, quedara: quedara),
    ) ??
    false;

class _ConfirmarAnulacion extends StatelessWidget {
  const _ConfirmarAnulacion({required this.venta, required this.quedara});

  static const _ancho = 500.0;

  final Movimiento venta;

  /// How the product is left, e.g. "26,5 kg (1 saco + 11,5 kg)".
  final String? quedara;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final alertas = context.coloresEstado;
    final espaciado = context.espaciado;
    final devuelto = venta.forma.unidad.formatear(venta.cantidad);
    final importe = venta.importe;
    final quedara = this.quedara;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _ancho),
        child: Padding(
          padding: EdgeInsets.all(espaciado.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: espaciado.lg,
            children: [
              Text(
                '¿Anular esta venta?',
                style: tema.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
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
                    children: [
                      Text(
                        '${venta.producto} · ${textoDetalleMovimiento(venta)}',
                        style: tema.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        [
                          if (importe != null) formatearDolares(importe),
                          textoHora(venta.fecha),
                        ].join(' · '),
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: colores.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'Se devuelven $devuelto al inventario'
                '${quedara == null ? '' : ': quedará $quedara'}. '
                'La venta queda en la lista como anulada.',
                style: tema.textTheme.bodyMedium,
              ),
              Row(
                spacing: espaciado.md,
                children: [
                  Expanded(
                    child: FilledButton(
                      autofocus: true,
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: alertas.textoAgotado,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: espaciado.sm,
                        children: [
                          const Flexible(
                            child: Text(
                              'Anular venta',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TeclaAtajo('Enter', color: colores.onPrimary),
                        ],
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: espaciado.sm,
                      children: [
                        const Text('No'),
                        TeclaAtajo('Esc', color: colores.onSurfaceVariant),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
