import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/motivo_devolucion.dart';

/// Alt+Z, X, C, V pick each reason, in declaration order.
const teclasMotivo = [
  LogicalKeyboardKey.keyZ,
  LogicalKeyboardKey.keyX,
  LogicalKeyboardKey.keyC,
  LogicalKeyboardKey.keyV,
];
const _letras = ['Z', 'X', 'C', 'V'];

class SelectorMotivoDevolucion extends StatelessWidget {
  const SelectorMotivoDevolucion({
    super.key,
    required this.motivo,
    required this.onMotivo,
  });

  final MotivoDevolucion motivo;
  final ValueChanged<MotivoDevolucion> onMotivo;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return ExcludeFocus(
      child: Wrap(
        spacing: espaciado.sm,
        runSpacing: espaciado.sm,
        children: [
          for (final (i, m) in MotivoDevolucion.values.indexed)
            ChoiceChip(
              label: Text('${m.etiqueta} · Alt+${_letras[i]}'),
              selected: m == motivo,
              showCheckmark: false,
              onSelected: (_) => onMotivo(m),
            ),
        ],
      ),
    );
  }
}
