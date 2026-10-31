import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/entradas/presentation/campo_cantidad_recibida.dart';
import 'package:inventario/features/incidencias/domain/sacar_de_lote.dart';
import 'package:inventario/features/incidencias/presentation/casilla_sacar.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/proveedores/domain/suministro.dart';

/// Affected pieces and weight, whether they leave the stock, and a note.
class CamposIncidencia extends StatelessWidget {
  const CamposIncidencia({
    super.key,
    required this.suministro,
    required this.piezas,
    required this.cantidad,
    required this.nota,
    required this.focoPiezas,
    required this.focoCantidad,
    required this.sacar,
    required this.onSacar,
    required this.onEnviar,
  });

  final Suministro suministro;
  final TextEditingController piezas;
  final TextEditingController cantidad;
  final TextEditingController nota;
  final FocusNode focoPiezas;
  final FocusNode focoCantidad;
  final bool sacar;
  final ValueChanged<bool> onSacar;

  /// Enter on the note.
  final VoidCallback onEnviar;

  /// "Marca A quedará en 8 piezas · 6,6 kg" for what is typed so far.
  String? _quedara() {
    final (:producto, :lote) = suministro;
    final unidad = producto.forma.unidad;
    final restado = sacarDeLote(
      producto,
      marca: lote.marca,
      proveedor: lote.proveedor,
      piezas: CampoCantidadRecibida.leer(piezas, 0),
      cantidad: CampoCantidadRecibida.leer(
        cantidad,
        unidad.decimales,
        unidad: unidad,
      ),
    );
    if (restado == null) return 'Solo hay ${textoLote(producto, lote)}';
    final despues =
        restado.lotes[indiceLote(restado, lote.marca, lote.proveedor)];
    return '${lote.marca} quedará en ${textoLote(restado, despues)}';
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final (:producto, :lote) = suministro;
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
                flex: 2,
                child: CampoCantidadRecibida(
                  etiqueta: 'Piezas afectadas',
                  controller: piezas,
                  focusNode: focoPiezas,
                  decimales: 0,
                  opcional: true,
                  maximo: sacar ? lote.piezas : null,
                ),
              ),
            Expanded(
              flex: 2,
              child: CampoCantidadRecibida(
                etiqueta: forma.cuentaPiezas ? 'Peso' : 'Cantidad',
                controller: cantidad,
                focusNode: focoCantidad,
                decimales: forma.unidad.decimales,
                sufijo: forma.unidad.simbolo,
                unidad: forma.unidad,
                maximo: sacar ? lote.cantidad : null,
              ),
            ),
            Expanded(
              flex: 3,
              child: ListenableBuilder(
                listenable: Listenable.merge([piezas, cantidad]),
                builder: (context, _) => CasillaSacar(
                  marcada: sacar,
                  detalle: _quedara(),
                  onCambiar: onSacar,
                ),
              ),
            ),
          ],
        ),
        TextFormField(
          controller: nota,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Qué se vio (opcional)',
            hintText: 'Dos piezas con moho al abrir la caja…',
          ),
          onFieldSubmitted: (_) => onEnviar(),
        ),
      ],
    );
  }
}
