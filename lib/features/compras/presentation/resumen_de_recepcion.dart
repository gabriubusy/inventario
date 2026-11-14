import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/compras/domain/resumen_recepcion.dart';

/// What saving the reception will do, beside the lines being counted.
class ResumenDeRecepcion extends StatelessWidget {
  const ResumenDeRecepcion({
    super.key,
    required this.resumen,
    required this.total,
    required this.guardando,
    required this.onGuardar,
  });

  final ResumenRecepcion resumen;

  /// Lines on the order, to read "3 de 4" against.
  final int total;
  final bool guardando;
  final VoidCallback onGuardar;

  String get _diferencia {
    final valor = resumen.diferencia;
    if (valor == 0) return 'Cuadra';
    final signo = valor > 0 ? '+' : '−';
    return '$signo${formatearDolares(valor.abs())}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final alertas = context.coloresEstado;
    final espaciado = context.espaciado;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: espaciado.md,
      children: [
        // Scrolls: a short window must not hide the save button.
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: espaciado.md,
              children: [
                _Tarjeta(
                  fondo: colores.surfaceContainerHighest,
                  borde: colores.outlineVariant,
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: espaciado.sm,
                    children: [
                      Text(
                        'AL GUARDAR',
                        style: tema.textTheme.labelSmall?.copyWith(
                          color: colores.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      for (final (titulo, valor) in [
                        (
                          'Entra al stock',
                          '${resumen.lineas} de $total líneas',
                        ),
                        (
                          'Valor de lo recibido',
                          formatearDolares(resumen.valor),
                        ),
                        ('Diferencia con lo pedido', _diferencia),
                        ('Líneas con diferencia', '${resumen.conDiferencia}'),
                      ])
                        Row(
                          spacing: espaciado.sm,
                          children: [
                            Expanded(
                              child: Text(
                                titulo,
                                style: tema.textTheme.bodySmall?.copyWith(
                                  color: colores.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Text(
                              valor,
                              style: tema.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (resumen.conDiferencia > 0)
                  _Tarjeta(
                    fondo: alertas.fondoBajo,
                    borde: alertas.textoBajo,
                    hijo: Text(
                      '${resumen.conDiferencia == 1 ? 'Una línea llegó' : '${resumen.conDiferencia} líneas llegaron'} '
                      'con algo distinto a lo pedido. El pedido queda recibido con '
                      'diferencias y la deuda de la factura no cambia.',
                      style: TextStyle(color: alertas.textoBajo),
                    ),
                  )
                else
                  _Tarjeta(
                    fondo: colores.surfaceContainerHighest,
                    borde: colores.outlineVariant,
                    hijo: Text(
                      'Lo que llegó entra al stock de su marca y el historial del '
                      'producto (F8) anota una entrada por línea.',
                      style: TextStyle(color: colores.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
        ),
        FilledButton(
          onPressed: guardando || resumen.vacia ? null : onGuardar,
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: espaciado.sm,
            children: [
              const Flexible(
                child: Text(
                  'Guardar la recepción',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TeclaAtajo('Ctrl+S', color: colores.onPrimary),
            ],
          ),
        ),
        Text(
          resumen.vacia
              ? 'Escribe lo que llegó de al menos una línea'
              : 'Alt+T llegó todo · Esc cierra el panel',
          textAlign: TextAlign.center,
          style: tema.textTheme.bodySmall?.copyWith(
            color: colores.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({
    required this.fondo,
    required this.borde,
    required this.hijo,
  });

  final Color fondo;
  final Color borde;
  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fondo,
        border: Border.all(color: borde),
        borderRadius: BorderRadius.circular(espaciado.sm + 2),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.md,
          vertical: espaciado.sm + 2,
        ),
        child: hijo,
      ),
    );
  }
}
