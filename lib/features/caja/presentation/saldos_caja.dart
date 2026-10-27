import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/textos_dinero.dart';

/// "Debería haber ahora": one line per way of paying, and the total in $.
class SaldosCaja extends StatelessWidget {
  const SaldosCaja({super.key, required this.saldos, required this.total});

  final Map<MedioPago, int> saldos;

  /// Everything in dollar hundredths at today's rate.
  final int total;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    const cifras = [FontFeature.tabularFigures()];
    Widget fila(String texto, String valor, {bool fuerte = false}) => Padding(
      padding: EdgeInsets.symmetric(
        horizontal: espaciado.lg,
        vertical: espaciado.md,
      ),
      child: Row(
        children: [
          Expanded(child: Text(texto, style: tema.textTheme.bodyMedium)),
          Text(
            valor,
            style:
                (fuerte
                        ? tema.textTheme.titleLarge
                        : tema.textTheme.titleMedium)
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: cifras,
                    ),
          ),
        ],
      ),
    );
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(espaciado.lg),
            child: Text(
              'Debería haber ahora',
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (saldos.isEmpty)
            Padding(
              padding: EdgeInsets.all(espaciado.lg),
              child: Text(
                'Aún no se ha movido dinero.',
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: colores.onSurfaceVariant,
                ),
              ),
            ),
          for (final MapEntry(key: medio, value: monto) in saldos.entries) ...[
            Divider(height: 1, color: colores.outlineVariant),
            fila(medio.etiqueta, textoEnMoneda(monto, medio.moneda)),
          ],
          Divider(height: 1, thickness: 2, color: colores.onSurface),
          fila(
            'Total en \$ a tasa de hoy',
            formatearDolares(total),
            fuerte: true,
          ),
        ],
      ),
    );
  }
}
