import 'package:flutter/material.dart';
import 'package:inventario/core/dinero.dart';

/// The amount in dollars and bolívares, with how it is worked out.
/// Shows a dash until there is a quantity, instead of "$ 0,00".
class ImporteSalida extends StatelessWidget {
  const ImporteSalida({
    super.key,
    required this.porUnidad,
    required this.cantidad,
    required this.importe,
    required this.aBolivares,
  });

  /// "$ 2,20 /kg" or "$ 30,00 /saco"; null when there is no price.
  final String? porUnidad;

  /// "2,5 kg" or "1 saco"; null while nothing valid is typed.
  final String? cantidad;
  final int? importe;
  final int? Function(int dolares) aBolivares;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    const cifras = [FontFeature.tabularFigures()];
    final secundario = tema.textTheme.bodySmall?.copyWith(
      color: colores.onSurfaceVariant,
      fontFeatures: cifras,
    );
    final porUnidad = this.porUnidad;
    if (porUnidad == null) {
      return Text(
        'Esta marca no tiene precio:\nse registra sin importe',
        textAlign: TextAlign.right,
        style: secundario,
      );
    }
    final cantidad = this.cantidad;
    final importe = cantidad == null ? null : this.importe;
    final bolivares = importe == null ? null : aBolivares(importe);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Importe', style: secundario),
        Text(
          importe == null ? '—' : formatearDolares(importe),
          style: tema.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: importe == null ? colores.onSurfaceVariant : null,
            fontFeatures: cifras,
          ),
        ),
        if (bolivares != null)
          Text(
            formatearBolivares(bolivares),
            style: tema.textTheme.bodyMedium?.copyWith(fontFeatures: cifras),
          ),
        Text(
          cantidad == null ? porUnidad : '$cantidad × $porUnidad',
          style: secundario,
        ),
      ],
    );
  }
}
