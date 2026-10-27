import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/proveedores/domain/suministro.dart';

/// What the supplier brings, one option per product and brand, Alt+1… each.
class OpcionesSuministro extends StatelessWidget {
  const OpcionesSuministro({
    super.key,
    required this.suministros,
    required this.elegido,
    required this.onElegir,
  });

  static const _columnas = 3;

  final List<Suministro> suministros;
  final int? elegido;
  final ValueChanged<int> onElegir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    if (suministros.isEmpty) {
      return Text(
        'Este proveedor aún no tiene productos. Aparecen al registrar una '
        'entrada (F2) con él.',
        style: tema.textTheme.bodyMedium?.copyWith(
          color: tema.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, limites) {
        final ancho =
            (limites.maxWidth - espaciado.sm * (_columnas - 1)) / _columnas;
        return Wrap(
          spacing: espaciado.sm,
          runSpacing: espaciado.sm,
          children: [
            for (final (i, s) in suministros.indexed)
              SizedBox(
                width: ancho,
                child: OpcionSeleccionable(
                  titulo: s.producto.nombre,
                  detalle: '${s.lote.marca} · ${textoLote(s.producto, s.lote)}',
                  elegida: elegido == i,
                  onPulsar: () => onElegir(i),
                ),
              ),
          ],
        );
      },
    );
  }
}
