import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/features/productos/presentation/interruptor_dos_opciones.dart';
import 'package:inventario/features/salidas/domain/modo_venta.dart';

/// Alt+P whole piece, Alt+K by weight.
const teclasModoVenta = {
  ModoVenta.piezaEntera: (LogicalKeyboardKey.keyP, 'Alt+P'),
  ModoVenta.porPeso: (LogicalKeyboardKey.keyK, 'Alt+K'),
};

/// What each way of selling means, shown on hover over its label.
final ayudaModoVenta = [
  for (final modo in ModoVenta.values)
    '${modo.etiqueta}: ${modo.detalle} · ${teclasModoVenta[modo]?.$2 ?? ''}',
].join('\n');

class SelectorModoVenta extends StatelessWidget {
  const SelectorModoVenta({
    super.key,
    required this.elegido,
    required this.onElegir,
  });

  final ModoVenta elegido;
  final ValueChanged<ModoVenta> onElegir;

  @override
  Widget build(BuildContext context) {
    return InterruptorDosOpciones(
      primera: ModoVenta.piezaEntera.etiqueta,
      segunda: ModoVenta.porPeso.etiqueta,
      esSegunda: elegido == ModoVenta.porPeso,
      onCambiar: (porPeso) =>
          onElegir(porPeso ? ModoVenta.porPeso : ModoVenta.piezaEntera),
    );
  }
}
