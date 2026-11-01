import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/entradas/presentation/controlador_cantidad.dart';

/// "kg | g" inside a quantity field: says how a bare number is read.
class SelectorUnidadMinima extends StatelessWidget {
  const SelectorUnidadMinima({
    super.key,
    required this.unidad,
    required this.controller,
  });

  final UnidadBase unidad;
  final ControladorCantidad controller;

  @override
  Widget build(BuildContext context) {
    // Out of the focus order, so Enter still jumps to the next field.
    return ExcludeFocus(
      child: Padding(
        padding: EdgeInsetsDirectional.only(end: context.espaciado.sm),
        child: SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text(unidad.simbolo)),
            ButtonSegment(value: true, label: Text(unidad.simboloMinimo)),
          ],
          selected: {controller.enMinimo},
          onSelectionChanged: (valor) => controller.enMinimo = valor.first,
          showSelectedIcon: false,
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}
