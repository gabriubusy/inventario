import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/salidas/domain/ticket.dart';
import 'package:inventario/features/salidas/presentation/textos_ticket.dart';

/// The lines rung up so far, newest last; the chosen one can be removed.
class TablaTicket extends StatelessWidget {
  const TablaTicket({
    super.key,
    required this.ticket,
    required this.elegida,
    required this.onElegir,
    required this.onQuitar,
  });

  static const _altoMaximo = 260.0;
  static const _anchoImporte = 96.0;

  final Ticket ticket;

  /// Index of the highlighted line, if any.
  final int? elegida;
  final ValueChanged<int> onElegir;
  final ValueChanged<int> onQuitar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    if (ticket.vacio) {
      return Text(
        'El ticket está vacío: agrega productos con Enter.',
        style: tema.textTheme.bodyMedium?.copyWith(
          color: colores.onSurfaceVariant,
        ),
      );
    }
    const cifras = [FontFeature.tabularFigures()];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surfaceContainerLowest,
        border: Border.all(color: colores.outlineVariant),
        borderRadius: BorderRadius.circular(espaciado.md),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _altoMaximo),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: ticket.lineas.length,
          itemBuilder: (context, i) {
            final linea = ticket.lineas[i];
            final importe = linea.importe;
            return Material(
              color: i == elegida
                  ? colores.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              child: InkWell(
                onTap: () => onElegir(i),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    espaciado.lg,
                    espaciado.sm,
                    espaciado.xs,
                    espaciado.sm,
                  ),
                  child: Row(
                    spacing: espaciado.md,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              linea.producto,
                              style: tema.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              textoLineaTicket(linea),
                              style: tema.textTheme.bodySmall?.copyWith(
                                color: colores.onSurfaceVariant,
                                fontFeatures: cifras,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: _anchoImporte,
                        child: Text(
                          importe == null
                              ? 'Sin precio'
                              : formatearDolares(importe),
                          textAlign: TextAlign.right,
                          style: tema.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFeatures: cifras,
                          ),
                        ),
                      ),
                      ExcludeFocus(
                        child: IconButton(
                          tooltip: 'Quitar del ticket',
                          icon: const Icon(Icons.close),
                          onPressed: () => onQuitar(i),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
