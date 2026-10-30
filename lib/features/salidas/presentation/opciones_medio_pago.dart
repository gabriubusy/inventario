import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/rejilla_adaptable.dart';
import 'package:inventario/core/medio_pago.dart';

/// Alt+1… picks the way of paying, in [MedioPago.values] order.
const teclasMedioPago = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
];

/// "Efectivo $ · Alt+1" per way offered, for its label's hover help.
String ayudaMediosPago([List<MedioPago> medios = MedioPago.values]) =>
    [for (final m in medios) '${m.etiqueta} · Alt+${m.index + 1}'].join('\n');

class OpcionesMedioPago extends StatelessWidget {
  const OpcionesMedioPago({
    super.key,
    required this.elegido,
    required this.onElegir,
    this.medios = MedioPago.values,
  });

  static const _anchoMinimo = 180.0;
  static const _alto = 52.0;

  final MedioPago elegido;
  final ValueChanged<MedioPago> onElegir;

  /// The ways offered; each keeps its Alt+number from [MedioPago.values].
  final List<MedioPago> medios;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final espaciado = context.espaciado;
    return RejillaAdaptable(
      anchoMinimo: _anchoMinimo,
      espacio: espaciado.sm,
      children: [
        for (final medio in medios)
          ExcludeFocus(
            child: OutlinedButton(
              onPressed: () => onElegir(medio),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(_alto),
                backgroundColor: medio == elegido
                    ? colores.primary.withValues(alpha: 0.10)
                    : null,
                side: BorderSide(
                  color: medio == elegido
                      ? colores.primary
                      : colores.outlineVariant,
                  width: medio == elegido ? 2 : 1,
                ),
              ),
              child: Text(
                medio.etiqueta,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colores.onSurface,
                  fontWeight: medio == elegido
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
