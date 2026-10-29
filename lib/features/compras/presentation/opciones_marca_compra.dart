import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// The brands this supplier already brings of the product, plus "Otra
/// marca"; Alt+1… each.
class OpcionesMarcaCompra extends StatelessWidget {
  const OpcionesMarcaCompra({
    super.key,
    required this.producto,
    required this.lotes,
    required this.elegido,
    required this.onElegir,
    this.conOtraMarca = true,
  });

  static const _columnas = 3;

  final Producto producto;

  /// Only this supplier's lots, in the product's order.
  final List<LoteMarca> lotes;

  /// Index in [lotes]; null means a new brand.
  final int? elegido;
  final ValueChanged<int?> onElegir;
  final bool conOtraMarca;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return LayoutBuilder(
      builder: (context, limites) {
        final ancho =
            (limites.maxWidth - espaciado.sm * (_columnas - 1)) / _columnas;
        return Wrap(
          spacing: espaciado.sm,
          runSpacing: espaciado.sm,
          children: [
            for (final (i, lote) in lotes.indexed)
              SizedBox(
                width: ancho,
                child: OpcionSeleccionable(
                  titulo: lote.marca,
                  detalle: 'Hay ${textoLote(producto, lote)}',
                  elegida: elegido == i,
                  onPulsar: () => onElegir(i),
                ),
              ),
            if (conOtraMarca)
              SizedBox(
                width: ancho,
                child: OpcionSeleccionable(
                  titulo: '+ Otra marca',
                  detalle: 'Nueva para este proveedor',
                  elegida: elegido == null,
                  onPulsar: () => onElegir(null),
                ),
              ),
          ],
        );
      },
    );
  }
}
