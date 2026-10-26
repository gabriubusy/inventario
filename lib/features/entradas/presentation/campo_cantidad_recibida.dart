import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/core/numeros.dart';

/// Required amount received; zero is not an entry.
class CampoCantidadRecibida extends StatelessWidget {
  const CampoCantidadRecibida({
    super.key,
    required this.etiqueta,
    required this.controller,
    required this.focusNode,
    required this.decimales,
    this.sufijo,
  });

  static final _caracteres = FilteringTextInputFormatter.allow(
    RegExp('[0-9.,]'),
  );

  final String etiqueta;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int decimales;
  final String? sufijo;

  /// Value of a field that passed validation; 0 when it is not valid yet.
  static int leer(TextEditingController controller, int decimales) =>
      parseDecimal(controller.text, decimales: decimales) ?? 0;

  String? _validar(String? texto) {
    if (texto == null || texto.trim().isEmpty) return 'Falta';
    final valor = parseDecimal(texto, decimales: decimales);
    if (valor == null) return decimales == 0 ? 'Solo enteros' : 'Ej.: 2,5';
    if (valor <= 0) return 'Mayor que 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.numberWithOptions(decimal: decimales > 0),
      inputFormatters: [_caracteres],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: etiqueta, suffixText: sufijo),
      validator: _validar,
    );
  }
}
