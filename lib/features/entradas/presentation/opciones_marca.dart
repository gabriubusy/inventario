import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// One option per brand lot of the product plus "Otra marca", Alt+1… each.
class OpcionesMarca extends StatelessWidget {
  const OpcionesMarca({
    super.key,
    required this.producto,
    required this.elegido,
    required this.onElegir,
  });

  static const _columnas = 3;

  final Producto producto;

  /// Index of the chosen lot; null means a new brand.
  final int? elegido;
  final ValueChanged<int?> onElegir;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final lotes = producto.lotes;
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
                  detalle: [
                    if (lote.proveedor.isNotEmpty) lote.proveedor,
                    textoLote(producto, lote),
                  ].join(' · '),
                  elegida: elegido == i,
                  onPulsar: () => onElegir(i),
                ),
              ),
            SizedBox(
              width: ancho,
              child: OpcionSeleccionable(
                titulo: '+ Otra marca',
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
