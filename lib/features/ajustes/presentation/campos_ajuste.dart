import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/entradas/presentation/campo_cantidad_recibida.dart';
import 'package:inventario/features/incidencias/domain/sacar_de_lote.dart';
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

  /// "Propia quedará: 3,8 kg → 3,4 kg" while the amounts fit.
  String? _quedara() {
    final restado = sacarDeLote(
      producto,
      marca: lote.marca,
      proveedor: lote.proveedor,
      piezas: CampoCantidadRecibida.leer(piezas, 0),
      cantidad: CampoCantidadRecibida.leer(
        cantidad,
        producto.forma.unidad.decimales,
      ),
    );
    if (restado == null) return null;
    final despues =
        restado.lotes[indiceLote(restado, lote.marca, lote.proveedor)];
    return '${lote.marca} quedará: ${textoLote(producto, lote)} → '
        '${textoLote(restado, despues)}';
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
                maximo: lote.cantidad,
              ),
            ),
          ],
        ),
        ListenableBuilder(
          listenable: Listenable.merge([piezas, cantidad]),
          builder: (context, _) {
            final quedara = _quedara();
            return Text(
              quedara ?? 'Solo hay ${textoLote(producto, lote)}',
              style: tema.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: quedara == null ? tema.colorScheme.error : null,
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
