import 'package:flutter/material.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/productos/presentation/campo_cantidad.dart';

/// Price in dollars per unit, with its value in bolívares underneath.
class CampoPrecio extends StatelessWidget {
  const CampoPrecio({
    super.key,
    required this.controller,
    required this.unidad,
    this.etiqueta = 'Precio',
    this.aBolivares,
  });

  final TextEditingController controller;
  final String etiqueta;
  final UnidadBase unidad;

  /// Null hides the bolívares line, e.g. before any rate is saved.
  final int? Function(int dolares)? aBolivares;

  String _enBolivares() {
    final convertir = aBolivares;
    final dolares = parseDecimal(controller.text, decimales: decimalesDinero);
    if (convertir == null || dolares == null) return '';
    final bolivares = convertir(dolares);
    return bolivares == null ? '' : '= ${formatearBolivares(bolivares)}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CampoCantidad(
          etiqueta: etiqueta,
          controller: controller,
          decimales: decimalesDinero,
          sufijo: '\$/${unidad.simbolo}',
        ),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => Text(
            _enBolivares(),
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
