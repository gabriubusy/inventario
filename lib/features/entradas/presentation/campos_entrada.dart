import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/entradas/presentation/campo_cantidad_recibida.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/presentation/campo_proveedor.dart';

/// Brand and supplier (typed only for a new brand), the amounts and a note.
class CamposEntrada extends StatelessWidget {
  const CamposEntrada({
    super.key,
    required this.forma,
    required this.lote,
    required this.marca,
    required this.proveedor,
    required this.piezas,
    required this.cantidad,
    required this.nota,
    required this.focoMarca,
    required this.focoProveedor,
    required this.focoPiezas,
    required this.focoCantidad,
    required this.proveedores,
    required this.onEnviar,
  });

  final FormaConteo forma;

  /// The chosen existing lot, or null for a new brand.
  final LoteMarca? lote;
  final TextEditingController marca;
  final TextEditingController proveedor;
  final TextEditingController piezas;
  final TextEditingController cantidad;
  final TextEditingController nota;
  final FocusNode focoMarca;
  final FocusNode focoProveedor;
  final FocusNode focoPiezas;
  final FocusNode focoCantidad;
  final List<String> proveedores;

  /// Enter on the last field.
  final VoidCallback onEnviar;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final lote = this.lote;
    final unidad = forma.unidad;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: espaciado.lg,
      children: [
        if (lote == null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: espaciado.md,
            children: [
              Expanded(
                child: TextFormField(
                  controller: marca,
                  focusNode: focoMarca,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Marca'),
                  validator: (texto) => (texto == null || texto.trim().isEmpty)
                      ? 'Falta la marca'
                      : null,
                ),
              ),
              Expanded(
                child: CampoProveedor(
                  controller: proveedor,
                  focusNode: focoProveedor,
                  sugerencias: proveedores,
                ),
              ),
            ],
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: espaciado.md,
          children: [
            if (lote != null)
              Expanded(
                flex: 3,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Proveedor',
                    enabled: false,
                  ),
                  child: Text(lote.proveedor.isEmpty ? '—' : lote.proveedor),
                ),
              ),
            if (forma.cuentaPiezas)
              Expanded(
                flex: 2,
                child: CampoCantidadRecibida(
                  etiqueta: 'Piezas',
                  controller: piezas,
                  focusNode: focoPiezas,
                  decimales: 0,
                ),
              ),
            Expanded(
              flex: 2,
              child: CampoCantidadRecibida(
                etiqueta: forma.cuentaPiezas ? 'Peso' : 'Cantidad',
                controller: cantidad,
                focusNode: focoCantidad,
                decimales: unidad.decimales,
                sufijo: unidad.simbolo,
              ),
            ),
          ],
        ),
        TextFormField(
          controller: nota,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nota (opcional)',
            hintText: 'N° de factura, observaciones…',
          ),
          onFieldSubmitted: (_) => onEnviar(),
        ),
      ],
    );
  }
}
