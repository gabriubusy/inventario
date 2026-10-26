import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/core/numeros.dart';

/// Numeric field in Venezuelan format; empty means 0 unless [obligatorio].
class CampoCantidad extends StatelessWidget {
  const CampoCantidad({
    super.key,
    required this.etiqueta,
    required this.controller,
    required this.decimales,
    this.sufijo,
    this.obligatorio = _nunca,
    this.onSubmitted,
    this.autofocus = false,
  });

  static final _caracteres = FilteringTextInputFormatter.allow(
    RegExp('[0-9.,]'),
  );

  final String etiqueta;
  final TextEditingController controller;
  final int decimales;
  final String? sufijo;

  /// Asked at validation time, so it can depend on the rest of the row.
  final bool Function() obligatorio;

  /// Without it, Enter just moves to the next field.
  final VoidCallback? onSubmitted;
  final bool autofocus;

  static bool _nunca() => false;

  /// Stored value of a field that already passed validation.
  static int leer(TextEditingController controller, int decimales) =>
      parseDecimal(controller.text, decimales: decimales) ?? 0;

  String? _validar(String? texto) {
    if (texto == null || texto.trim().isEmpty) {
      return obligatorio() ? 'Falta' : null;
    }
    if (parseDecimal(texto, decimales: decimales) != null) return null;
    return decimales == 0 ? 'Solo enteros' : 'Ej.: 2,5';
  }

  @override
  Widget build(BuildContext context) {
    final onSubmitted = this.onSubmitted;
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.numberWithOptions(decimal: decimales > 0),
      inputFormatters: [_caracteres],
      textInputAction: onSubmitted == null
          ? TextInputAction.next
          : TextInputAction.done,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: '0',
        suffixText: sufijo,
      ),
      validator: _validar,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
    );
  }
}
