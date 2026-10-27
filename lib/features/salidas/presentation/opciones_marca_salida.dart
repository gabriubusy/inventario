import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/salidas/presentation/opcion_tarjeta.dart';

/// One card per brand lot with its price, stock and supplier, Alt+1… each.
/// Unlike entries there is no "other brand": only what is in stock sells.
class OpcionesMarcaSalida extends StatelessWidget {
  const OpcionesMarcaSalida({
    super.key,
    required this.producto,
    required this.elegido,
    required this.onElegir,
    this.atajos = const [],
  });

  static const _columnas = 2;

  final Producto producto;
  final int? elegido;
  final ValueChanged<int> onElegir;

  /// Shortcut shown on each card; Alt+1… unless packs took the digits.
  final List<String> atajos;

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
            for (final (i, lote) in producto.lotes.indexed)
              SizedBox(
                width: ancho,
                child: OpcionTarjeta(
                  elegida: elegido == i,
                  onPulsar: () => onElegir(i),
                  child: _Marca(
                    producto: producto,
                    lote: lote,
                    atajo: i < atajos.length ? atajos[i] : 'Alt+${i + 1}',
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca({
    required this.producto,
    required this.lote,
    required this.atajo,
  });

  final Producto producto;
  final LoteMarca lote;
  final String atajo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    const cifras = [FontFeature.tabularFigures()];
    final secundario = tema.textTheme.bodySmall?.copyWith(
      color: colores.onSurfaceVariant,
      fontFeatures: cifras,
    );
    final precio = lote.precio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.espaciado.xs / 2,
      children: [
        Row(
          spacing: context.espaciado.sm,
          children: [
            Expanded(
              child: Text(
                lote.marca,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TeclaAtajo(atajo, color: colores.onSurfaceVariant),
          ],
        ),
        Text(
          precio == null
              ? 'Sin precio'
              : '${formatearDolares(precio)} /${producto.forma.unidad.simbolo}',
          style: precio == null
              ? secundario?.copyWith(fontStyle: FontStyle.italic)
              : tema.textTheme.titleMedium?.copyWith(
                  color: colores.primary,
                  fontWeight: FontWeight.w700,
                  fontFeatures: cifras,
                ),
        ),
        Text(textoLote(producto, lote), style: secundario),
        Text(
          lote.proveedor.isEmpty ? 'Sin proveedor' : lote.proveedor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: secundario,
        ),
      ],
    );
  }
}
