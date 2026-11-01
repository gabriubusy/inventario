import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/entradas/presentation/controlador_cantidad.dart';
import 'package:inventario/features/entradas/presentation/selector_unidad_minima.dart';

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

  /// "kg", "und" or the pack's name, after the number.
  final String sufijo;

  /// The most that can be typed, scaled like the field.
  final int disponible;
  final VoidCallback onEnviar;

  /// When sold in the product's own unit: then "250 g" or "500 ml" may be
  /// typed as well. Null for packs.
  final UnidadBase? unidad;

  /// Value of the field; 0 while it is empty or not a number yet.
  static int leer(
    TextEditingController controller,
    int decimales, {
    UnidadBase? unidad,
  }) =>
      _valor(
        controller.text,
        decimales,
        unidad,
        ControladorCantidad.de(controller),
      ) ??
      0;

  static int? _valor(
    String texto,
    int decimales,
    UnidadBase? unidad,
    bool enMinimo,
  ) => unidad == null
      ? parseDecimal(texto, decimales: decimales)
      : unidad.leer(texto, enMinimo: enMinimo);

  bool get _aceptaMinimo => unidad?.tieneMinimo ?? false;

  String get _ejemplo => switch (unidad) {
    final UnidadBase u when ControladorCantidad.de(controller) =>
      'Ej.: 250 ${u.simboloMinimo}',
    UnidadBase.kg => 'Ej.: 0,25 o 250 g',
    UnidadBase.litro => 'Ej.: 0,5 o 500 ml',
    _ => decimales == 0 ? 'Solo enteros' : 'Ej.: 2,5',
  };

  String? _validar(String? texto) {
    if (texto == null || texto.trim().isEmpty) return 'Falta';
    final valor = _valor(
      texto,
      decimales,
      unidad,
      ControladorCantidad.de(controller),
    );
    if (valor == null) return _ejemplo;
    if (valor <= 0) return 'Mayor que 0';
    if (valor > disponible) {
      return 'Solo hay ${formatDecimal(disponible, decimales: decimales)} '
          '$sufijo';
    }
    return null;
  }

  /// The "kg | g" selector, while no unit was typed in the text.
  Widget? _selector(bool conLetras) {
    final unidad = this.unidad;
    final controller = this.controller;
    if (conLetras || !_aceptaMinimo || controller is! ControladorCantidad) {
      return null;
    }
    return SelectorUnidadMinima(unidad: unidad!, controller: controller);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final conLetras = RegExp('[a-zA-Z]').hasMatch(controller.text);
    final selector = _selector(conLetras);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.right,
      keyboardType: unidad == null
          ? TextInputType.numberWithOptions(decimal: decimales > 0)
          : TextInputType.text,
      inputFormatters: [if (unidad == null) _numeros else _conUnidad],
      textInputAction: TextInputAction.done,
      style: tema.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        labelText: etiqueta,
        // "250 g" already says its unit; "kg" after it would contradict it.
        suffixText: conLetras || selector != null ? null : sufijo,
        suffixIcon: selector,
        helperText: _aceptaMinimo ? _ejemplo : null,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: _validar,
      onFieldSubmitted: (_) => onEnviar(),
    );
  }
}
