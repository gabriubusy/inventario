import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/conteo/domain/aplicar_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// Typed counts of one row; empty fields mean "not counted".
typedef CamposConteo = ({
  TextEditingController piezas,
  TextEditingController cantidad,
});

/// One brand lot: what the system says, what was counted, the difference.
class FilaConteo extends StatelessWidget {
  const FilaConteo({
    super.key,
    required this.producto,
    required this.lote,
    required this.campos,
    required this.diferencia,
  });

  static const _anchoCampo = 110.0;
  static const _anchoDiferencia = 150.0;
  static final _caracteres = FilteringTextInputFormatter.allow(
    RegExp('[0-9.,]'),
  );
  static final _conUnidad = FilteringTextInputFormatter.allow(
    RegExp('[0-9.,a-zA-Z ]'),
  );

  final Producto producto;
  final LoteMarca lote;
  final CamposConteo campos;

  /// Null while nothing was typed or the text is not a number.
  final DiferenciaConteo? diferencia;

  String _texto(DiferenciaConteo d) {
    final unidad = producto.forma.unidad;
    String signo(int n) => n > 0 ? '+' : '−';
    return [
      if (d.piezas != 0) '${signo(d.piezas)}${textoPiezas(d.piezas.abs())}',
      if (d.cantidad != 0)
        '${signo(d.cantidad)}${unidad.formatear(d.cantidad.abs())}',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final alertas = context.coloresEstado;
    final forma = producto.forma;
    final diferencia = this.diferencia;
    final cambia = diferencia != null && hayDiferencia(diferencia);
    final falta = cambia && (diferencia.cantidad < 0 || diferencia.piezas < 0);
    const cifras = [FontFeature.tabularFigures()];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cambia ? colores.primary.withValues(alpha: 0.04) : null,
        border: Border(top: BorderSide(color: colores.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.lg,
          vertical: espaciado.sm,
        ),
        child: Row(
          spacing: espaciado.md,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    lote.marca,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: colores.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                textoLote(producto, lote),
                textAlign: TextAlign.right,
                style: tema.textTheme.bodyMedium?.copyWith(
                  fontFeatures: cifras,
                ),
              ),
            ),
            if (forma.cuentaPiezas)
              SizedBox(
                width: _anchoCampo,
                child: _Campo(
                  controller: campos.piezas,
                  etiqueta: 'Piezas',
                  decimales: 0,
                ),
              ),
            SizedBox(
              width: _anchoCampo,
              child: _Campo(
                controller: campos.cantidad,
                etiqueta: forma.cuentaPiezas ? 'Peso' : 'Contado',
                decimales: forma.unidad.decimales,
                sufijo: forma.unidad.simbolo,
                conUnidad: true,
              ),
            ),
            SizedBox(
              width: _anchoDiferencia,
              child: Text(
                cambia ? _texto(diferencia) : '—',
                textAlign: TextAlign.right,
                style: tema.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: cifras,
                  color: !cambia
                      ? colores.onSurfaceVariant
                      : falta
                      ? alertas.textoAgotado
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Parses [texto] scaled by [decimales], or in [unidad] when given
  /// ("250 g" too); null when empty or not a number.
  static int? leer(String texto, int decimales, {UnidadBase? unidad}) {
    if (texto.trim().isEmpty) return null;
    return unidad == null
        ? parseDecimal(texto, decimales: decimales)
        : unidad.leer(texto);
  }
}

class _Campo extends StatelessWidget {
  const _Campo({
    required this.controller,
    required this.etiqueta,
    required this.decimales,
    this.sufijo,
    this.conUnidad = false,
  });

  final TextEditingController controller;
  final String etiqueta;
  final int decimales;
  final String? sufijo;

  /// Letters too, for "250 g".
  final bool conUnidad;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: conUnidad
          ? TextInputType.text
          : TextInputType.numberWithOptions(decimal: decimales > 0),
      inputFormatters: [
        if (conUnidad) FilaConteo._conUnidad else FilaConteo._caracteres,
      ],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: etiqueta,
        suffixText: sufijo,
        isDense: true,
      ),
    );
  }
}
