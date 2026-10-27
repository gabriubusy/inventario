import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/salidas/domain/modo_venta.dart';
import 'package:inventario/features/salidas/presentation/opcion_tarjeta.dart';

/// Alt+P whole piece, Alt+K by weight.
const teclasModoVenta = {
  ModoVenta.piezaEntera: (LogicalKeyboardKey.keyP, 'Alt+P'),
  ModoVenta.porPeso: (LogicalKeyboardKey.keyK, 'Alt+K'),
};

class SelectorModoVenta extends StatelessWidget {
  const SelectorModoVenta({
    super.key,
    required this.elegido,
    required this.onElegir,
  });

  final ModoVenta elegido;
  final ValueChanged<ModoVenta> onElegir;

  static IconData _icono(ModoVenta modo) => switch (modo) {
    ModoVenta.piezaEntera => Icons.scale_outlined,
    ModoVenta.porPeso => Icons.content_cut,
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return Row(
      spacing: espaciado.sm,
      children: [
        for (final modo in ModoVenta.values)
          Expanded(
            child: OpcionTarjeta(
              elegida: modo == elegido,
              onPulsar: () => onElegir(modo),
              child: Row(
                spacing: espaciado.md,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: modo == elegido
                          ? colores.primary
                          : colores.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(espaciado.sm),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(espaciado.sm),
                      child: Icon(
                        _icono(modo),
                        size: 20,
                        color: modo == elegido
                            ? colores.onPrimary
                            : colores.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: espaciado.sm,
                          children: [
                            Expanded(
                              child: Text(
                                modo.etiqueta,
                                style: tema.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TeclaAtajo(
                              teclasModoVenta[modo]?.$2 ?? '',
                              color: colores.onSurfaceVariant,
                            ),
                          ],
                        ),
                        Text(
                          modo.detalle,
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: colores.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
