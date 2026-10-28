import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/movimientos/presentation/textos_movimiento.dart';
import 'package:inventario/features/salidas/domain/grupo_ventas.dart';
import 'package:inventario/features/salidas/domain/venta.dart';

/// "18:12 · Ticket de 2 productos ··· Efectivo $ · $ 16,77" above its lines.
class EncabezadoTicket extends StatelessWidget {
  const EncabezadoTicket({super.key, required this.grupo, this.pagada});

  final GrupoVentas grupo;

  /// How it was paid; null for one-product sales made before tickets.
  final Venta? pagada;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final lineas = grupo.lineas.length;
    final medios = pagada?.pagos.map((p) => p.medio.etiqueta).toSet();
    return ColoredBox(
      color: colores.surfaceContainer,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.md,
          vertical: espaciado.sm,
        ),
        child: Row(
          spacing: espaciado.md,
          children: [
            Expanded(
              child: Text(
                '${textoHora(grupo.fecha)} · '
                '${grupo.ventaId == null
                    ? 'Venta suelta'
                    : lineas == 1
                    ? 'Ticket de 1 producto'
                    : 'Ticket de $lineas productos'}',
                style: tema.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              [
                if (medios != null && medios.isNotEmpty) medios.join(' + '),
                formatearDolares(grupo.total),
              ].join(' · '),
              style: tema.textTheme.labelLarge?.copyWith(
                color: colores.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
