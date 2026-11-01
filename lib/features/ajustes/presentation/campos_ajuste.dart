import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/entradas/presentation/campo_cantidad_recibida.dart';
import 'package:inventario/features/incidencias/domain/sacar_de_lote.dart';
import 'package:inventario/features/incidencias/presentation/texto_no_sale.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// Pieces and weight lost, what the brand keeps, and a note.
class CamposAjuste extends StatelessWidget {
  const CamposAjuste({
    super.key,
    required this.producto,
    required this.lote,
    required this.piezas,
    required this.cantidad,
    required this.nota,
    required this.focoPiezas,
    required this.focoCantidad,
    required this.onEnviar,
  });

  final Producto producto;
  final LoteMarca lote;
  final TextEditingController piezas;
  final TextEditingController cantidad;
  final TextEditingController nota;
  final FocusNode focoPiezas;
  final FocusNode focoCantidad;

  /// Enter on the note.
  final VoidCallback onEnviar;

  /// "Propia quedará: 3,8 kg → 3,4 kg", or why it can't (`ok: false`).
  ({String texto, bool ok}) _quedara() {
    final sacadas = CampoCantidadRecibida.leer(piezas, 0);
    final sacado = CampoCantidadRecibida.leer(
      cantidad,
      producto.forma.unidad.decimales,
      unidad: producto.forma.unidad,
    );
    final restado = sacarDeLote(
      producto,
      marca: lote.marca,
      proveedor: lote.proveedor,
      piezas: sacadas,
      cantidad: sacado,
    );
    if (restado == null) {
      return (
        texto: textoNoSale(producto, lote, piezas: sacadas, cantidad: sacado),
        ok: false,
      );
    }
    final despues =
        restado.lotes[indiceLote(restado, lote.marca, lote.proveedor)];
    return (
      texto:
          '${lote.marca} quedará: ${textoLote(producto, lote)} → '
          '${textoLote(restado, despues)}',
      ok: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final forma = producto.forma;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: espaciado.lg,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: espaciado.md,
          children: [
            if (forma.cuentaPiezas)
              Expanded(
                child: CampoCantidadRecibida(
                  etiqueta: 'Piezas',
                  controller: piezas,
                  focusNode: focoPiezas,
                  decimales: 0,
                  opcional: true,
                  maximo: lote.piezas,
                ),
              ),
            Expanded(
              child: CampoCantidadRecibida(
                etiqueta: forma.cuentaPiezas ? 'Peso' : 'Cantidad',
                controller: cantidad,
                focusNode: focoCantidad,
                decimales: forma.unidad.decimales,
                sufijo: forma.unidad.simbolo,
                unidad: forma.unidad,
                maximo: lote.cantidad,
              ),
            ),
          ],
        ),
        ListenableBuilder(
          listenable: Listenable.merge([piezas, cantidad]),
          builder: (context, _) {
            final vacio =
                piezas.text.trim().isEmpty && cantidad.text.trim().isEmpty;
            // Nothing typed yet: just what there is, nothing to warn about.
            final quedara = vacio
                ? (texto: 'Hay ${textoLote(producto, lote)}', ok: true)
                : _quedara();
            return Text(
              quedara.texto,
              style: tema.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: quedara.ok ? null : tema.colorScheme.error,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            );
          },
        ),
        TextFormField(
          controller: nota,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nota (opcional)',
            hintText: 'Qué pasó, quién lo vio…',
          ),
          onFieldSubmitted: (_) => onEnviar(),
        ),
      ],
    );
  }
}
