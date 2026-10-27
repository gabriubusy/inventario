import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/core/numeros.dart';

/// The big amount field; Enter here registers the sale, for speed.
class CampoCantidadVendida extends StatelessWidget {
  const CampoCantidadVendida({
    super.key,
    required this.etiqueta,
    required this.controller,
    required this.focusNode,
    required this.decimales,
    required this.sufijo,
    required this.disponible,
    required this.onEnviar,
  });

  static final _caracteres = FilteringTextInputFormatter.allow(
    RegExp('[0-9.,]'),
  );

  final String etiqueta;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int decimales;

  /// "kg", "und" or the pack's name, after the number.
  final String sufijo;

  /// The most that can be typed, scaled like the field.
  final int disponible;
  final VoidCallback onEnviar;

  /// Value of the field; 0 while it is empty or not a number yet.
  static int leer(TextEditingController controller, int decimales) =>
      parseDecimal(controller.text, decimales: decimales) ?? 0;

  String? _validar(String? texto) {
    if (texto == null || texto.trim().isEmpty) return 'Falta';
    final valor = parseDecimal(texto, decimales: decimales);
    if (valor == null) {
      return decimales == 0 ? 'Solo enteros' : 'Ej.: 2,5';
    }
    if (valor <= 0) return 'Mayor que 0';
    if (valor > disponible) {
      return 'Solo hay ${formatDecimal(disponible, decimales: decimales)} '
          '$sufijo';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.numberWithOptions(decimal: decimales > 0),
      inputFormatters: [_caracteres],
      textInputAction: TextInputAction.done,
      style: tema.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(labelText: etiqueta, suffixText: sufijo),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: _validar,
      onFieldSubmitted: (_) => onEnviar(),
    );
  }
}
