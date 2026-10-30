import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/salidas/presentation/opcion_tarjeta.dart';

/// "Marca · Alt+1" per brand of [producto], for its label's hover help.
/// [teclas] replaces Alt+1… when packs took the digits.
String ayudaMarcas(Producto producto, [List<String> teclas = const []]) =>
    lineasAyuda(
      [for (final l in producto.lotes) l.marca],
      [
        for (var i = 0; i < producto.lotes.length; i++)
          i < teclas.length ? teclas[i] : 'Alt+${i + 1}',
      ],
    ).join('\n');

/// One card per brand lot with its price, stock and supplier.
/// Unlike entries there is no "other brand": only what is in stock sells.
class OpcionesMarcaSalida extends StatelessWidget {
  const OpcionesMarcaSalida({
    super.key,
    required this.producto,
    required this.elegido,
    required this.onElegir,
  });

  static const _columnas = 2;

  final Producto producto;
  final int? elegido;
  final ValueChanged<int> onElegir;

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
                  child: _Marca(producto: producto, lote: lote),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca({required this.producto, required this.lote});

  final Producto producto;
  final LoteMarca lote;

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
        Text(
          lote.marca,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tema.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
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
