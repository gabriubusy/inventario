import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/entradas/domain/entrada.dart';
import 'package:inventario/features/entradas/domain/sumar_entrada.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// "Marca A quedará: 10 piezas · 8,2 kg → 16 piezas · 13,1 kg" and the
/// product total, before anything is saved.
class VistaPreviaEntrada extends StatelessWidget {
  const VistaPreviaEntrada({
    super.key,
    required this.producto,
    required this.entrada,
  });

  final Producto producto;
  final Entrada entrada;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final indice = indiceLoteDeEntrada(producto, entrada);
    final despues = sumarEntrada(producto, entrada);
    final lote =
        despues.lotes[indice == -1 ? despues.lotes.length - 1 : indice];
    final linea = indice == -1
        ? '${entrada.marca} (nueva) quedará: ${textoLote(despues, lote)}'
        : '${entrada.marca} quedará: '
              '${textoLote(producto, producto.lotes[indice])} → '
              '${textoLote(despues, lote)}';
    final peso = textoPeso(despues);
    final total =
        'Total del producto: ${textoPrincipal(despues)}'
        '${peso == null ? '' : ' · $peso'}';
    const cifras = [FontFeature.tabularFigures()];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surfaceContainerLowest,
        border: Border.all(color: colores.outlineVariant),
        borderRadius: BorderRadius.circular(espaciado.sm + 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(espaciado.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: espaciado.xs,
          children: [
            Text(
              linea,
              style: tema.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: cifras,
              ),
            ),
            Text(
              total,
              style: tema.textTheme.bodySmall?.copyWith(
                color: colores.onSurfaceVariant,
                fontFeatures: cifras,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
