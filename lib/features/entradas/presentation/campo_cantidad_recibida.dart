import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/unidad.dart';

/// Required amount received; zero is not an entry.
class CampoCantidadRecibida extends StatelessWidget {
  const CampoCantidadRecibida({
    super.key,
    required this.etiqueta,
    required this.controller,
    required this.focusNode,
    required this.decimales,
    this.sufijo,
    this.opcional = false,
    this.maximo,
    this.unidad,
  });

  static final _numeros = FilteringTextInputFormatter.allow(RegExp('[0-9.,]'));

  // Letters too, for "250 g" or "1,5 kg".
  static final _conUnidad = FilteringTextInputFormatter.allow(
    RegExp('[0-9.,a-zA-Z ]'),
  );

  final String etiqueta;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int decimales;
  final String? sufijo;

  /// Empty or zero is accepted, e.g. pieces when only weight went missing.
  final bool opcional;

  /// Upper limit, e.g. what the lot holds when taking goods out.
  final int? maximo;

  /// The product's unit for a weight or volume, so "250 g" or "500 ml" can
  /// be typed too; null for pieces and money.
  final UnidadBase? unidad;

  /// Value of a field that passed validation; 0 when it is not valid yet.
  static int leer(
    TextEditingController controller,
    int decimales, {
    UnidadBase? unidad,
  }) => _valor(controller.text, decimales, unidad) ?? 0;

  static int? _valor(String texto, int decimales, UnidadBase? unidad) =>
      unidad == null
      ? parseDecimal(texto, decimales: decimales)
      : unidad.leer(texto);

  String get _ejemplo => switch (unidad) {
    UnidadBase.kg => 'Ej.: 2,5 o 250 g',
    UnidadBase.litro => 'Ej.: 2,5 o 500 ml',
    _ => decimales == 0 ? 'Solo enteros' : 'Ej.: 2,5',
  };

  String? _validar(String? texto) {
    final vacio = texto == null || texto.trim().isEmpty;
    if (vacio) return opcional ? null : 'Falta';
    final valor = _valor(texto, decimales, unidad);
    if (valor == null) return _ejemplo;
    if (valor <= 0 && !opcional) return 'Mayor que 0';
    final maximo = this.maximo;
    if (maximo != null && valor > maximo) {
      return 'Solo hay ${formatDecimal(maximo, decimales: decimales)}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilt as it is typed: "300 g" already says its unit, so "kg" hides.
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.right,
        keyboardType: unidad == null
            ? TextInputType.numberWithOptions(decimal: decimales > 0)
            : TextInputType.text,
        inputFormatters: [if (unidad == null) _numeros else _conUnidad],
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: etiqueta,
          suffixText: RegExp('[a-zA-Z]').hasMatch(controller.text)
              ? null
              : sufijo,
        ),
        validator: _validar,
      ),
    );
  }
}
