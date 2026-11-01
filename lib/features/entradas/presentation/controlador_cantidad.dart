import 'package:flutter/widgets.dart';

/// Text of a weight or volume field plus whether a bare number is grams
/// or millilitres; kept here so it survives clearing the field.
class ControladorCantidad extends TextEditingController {
  ControladorCantidad({super.text});

  bool _enMinimo = false;

  bool get enMinimo => _enMinimo;

  set enMinimo(bool valor) {
    if (valor == _enMinimo) return;
    _enMinimo = valor;
    notifyListeners();
  }

  /// Mode of any controller; plain ones are always in the big unit.
  static bool de(TextEditingController controller) =>
      controller is ControladorCantidad && controller.enMinimo;
}
