import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// Ctrl+1… picks the most sold products, in the order shown.
const teclasMasVendidos = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
];

/// "Más vendidos": one button per product, each with its Ctrl+number.
class BotonesMasVendidos extends StatelessWidget {
  const BotonesMasVendidos({
    super.key,
    required this.productos,
    required this.onElegir,
  });

  static const _alto = 44.0;

  final List<Producto> productos;
  final ValueChanged<Producto> onElegir;

  @override
  Widget build(BuildContext context) {
    if (productos.isEmpty) return const SizedBox.shrink();
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: espaciado.sm,
      children: [
        Text(
          'Más vendidos',
          style: tema.textTheme.labelLarge?.copyWith(
            color: colores.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        Wrap(
          spacing: espaciado.sm,
          runSpacing: espaciado.sm,
          children: [
            for (final (i, producto) in productos.indexed)
              ExcludeFocus(
                child: OutlinedButton(
                  onPressed: () => onElegir(producto),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, _alto),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: espaciado.sm,
                    children: [
                      Text(
                        producto.nombre,
                        style: TextStyle(color: colores.onSurface),
                      ),
                      TeclaAtajo(
                        'Ctrl+${i + 1}',
                        color: colores.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
