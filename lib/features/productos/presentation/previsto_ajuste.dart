import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/productos/application/controlador_ajuste_precios.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/precio_en_lista.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// "Cambian 12 productos" and a few of them with their price before → after.
class PrevistoAjuste extends StatelessWidget {
  const PrevistoAjuste({super.key, required this.cambios, required this.lista});

  static const _muestras = 4;

  final List<CambioAjuste> cambios;
  final ListaPrecio lista;

  /// The first brand's price in [lista], or the first pack's.
  String? _precio(Producto producto) {
    for (final lote in producto.lotes) {
      if (precioDeLote(producto, lote, lista) case final precio?) {
        return '${formatearDolares(precio)}/${producto.forma.unidad.simbolo}';
      }
    }
    final pack = producto.presentaciones.firstOrNull;
    if (pack == null) return null;
    final lote = producto.lotes.firstOrNull;
    final precio = precioDePresentacion(producto, pack, lote, lista);
    return '${formatearDolares(precio)} ${pack.nombre.toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final suave = tema.textTheme.bodyMedium?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.espaciado.xs,
      children: [
        Text(switch (cambios.length) {
          0 => 'Ningún producto cambia: escribe el porcentaje o elige otros',
          1 => 'Cambia 1 producto',
          final n => 'Cambian $n productos',
        }, style: tema.textTheme.titleSmall),
        for (final cambio in cambios.take(_muestras))
          if ((_precio(cambio.antes), _precio(cambio.despues)) case (
            final antes?,
            final despues?,
          ))
            Text('${cambio.antes.nombre}: $antes → $despues', style: suave),
        if (cambios.length > _muestras)
          Text('y ${cambios.length - _muestras} más', style: suave),
      ],
    );
  }
}
