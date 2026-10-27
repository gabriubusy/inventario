import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// The chosen product with what there is now, and a way to pick another.
class ProductoElegido extends StatelessWidget {
  const ProductoElegido({
    super.key,
    required this.producto,
    required this.onCambiar,
  });

  final Producto producto;
  final VoidCallback onCambiar;

  String get _detalle {
    final peso = producto.forma.cuentaPiezas
        ? ' · ${producto.forma.unidad.formatear(producto.cantidad)}'
        : '';
    final abiertas = producto.piezasAbiertas > 0
        ? ' + ${producto.piezasAbiertas} abierta'
        : '';
    return '${producto.categoria.etiqueta} · '
        '${producto.forma.etiqueta.toLowerCase()} · '
        'hay ${textoStock(producto)}$abiertas$peso';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colores.primary, width: 2),
        borderRadius: BorderRadius.circular(espaciado.sm + 2),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.md,
          vertical: espaciado.sm + 2,
        ),
        child: Row(
          spacing: espaciado.md,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _detalle,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: colores.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            ExcludeFocus(
              child: TextButton(
                onPressed: onCambiar,
                child: const Text('Cambiar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
