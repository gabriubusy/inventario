import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/presentation/campo_cantidad.dart';
import 'package:inventario/features/productos/presentation/campo_precio.dart';
import 'package:inventario/features/productos/presentation/campo_proveedor.dart';
import 'package:inventario/features/productos/presentation/lote_editable.dart';

class FilaLote extends StatelessWidget {
  const FilaLote({
    super.key,
    required this.lote,
    required this.forma,
    required this.esRepetido,
    this.proveedores = const [],
    this.existenciaFija,
    this.aBolivares,
    this.onQuitar,
  });

  /// Below this width the row splits in two lines, as in the side panel.
  static const _anchoUnaLinea = 600.0;

  final LoteEditable lote;
  final FormaConteo forma;

  /// Saved supplier names offered while typing.
  final List<String> proveedores;

  /// Asked at validation time: an earlier row has the same brand and supplier.
  final bool Function() esRepetido;

  /// When editing, the stock is shown instead of typed.
  final String? existenciaFija;

  final int? Function(int dolares)? aBolivares;

  /// Null for rows that must stay.
  final VoidCallback? onQuitar;

  bool _enUso() => !lote.vacio;

  String? _validarMarca(String? texto) {
    if (lote.vacio) return null;
    if (texto == null || texto.trim().isEmpty) return 'Falta la marca';
    if (esRepetido()) return 'Ya está arriba';
    return null;
  }

  List<Widget> _identidad() => [
    Expanded(
      flex: 13,
      child: TextFormField(
        controller: lote.marca,
        focusNode: lote.focoMarca,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(labelText: 'Marca'),
        validator: _validarMarca,
      ),
    ),
    Expanded(
      flex: 13,
      child: CampoProveedor(
        controller: lote.proveedor,
        focusNode: lote.focoProveedor,
        sugerencias: proveedores,
      ),
    ),
  ];

  List<Widget> _cantidades() {
    final unidad = forma.unidad;
    final fija = existenciaFija;
    return [
      if (fija != null)
        Expanded(
          flex: 15,
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Hay'),
            child: Text(fija, maxLines: 2),
          ),
        )
      else ...[
        if (forma.cuentaPiezas)
          Expanded(
            flex: 7,
            child: CampoCantidad(
              etiqueta: 'Piezas',
              controller: lote.piezas,
              decimales: 0,
              obligatorio: _enUso,
            ),
          ),
        Expanded(
          flex: 8,
          child: CampoCantidad(
            etiqueta: forma.cuentaPiezas ? 'Peso' : 'Cantidad',
            controller: lote.cantidad,
            decimales: unidad.decimales,
            sufijo: unidad.simbolo,
            obligatorio: _enUso,
          ),
        ),
      ],
      Expanded(
        flex: 10,
        child: CampoPrecio(
          controller: lote.precio,
          unidad: unidad,
          aBolivares: aBolivares,
        ),
      ),
    ];
  }

  Widget? _quitar() {
    final onQuitar = this.onQuitar;
    if (onQuitar == null) return null;
    return ExcludeFocus(
      child: IconButton(
        tooltip: 'Quitar marca',
        icon: const Icon(Icons.close),
        onPressed: onQuitar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final quitar = _quitar();
    return LayoutBuilder(
      builder: (context, limites) {
        if (limites.maxWidth >= _anchoUnaLinea) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: espaciado.sm,
            children: [..._identidad(), ..._cantidades(), ?quitar],
          );
        }
        return Column(
          spacing: espaciado.sm,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: espaciado.sm,
              children: [..._identidad(), ?quitar],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: espaciado.sm,
              children: _cantidades(),
            ),
          ],
        );
      },
    );
  }
}
