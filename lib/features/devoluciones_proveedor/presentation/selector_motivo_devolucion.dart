import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/motivo_devolucion.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';

/// Alt+Z, X, C, V pick each reason, in declaration order.
const teclasMotivo = [
  LogicalKeyboardKey.keyZ,
  LogicalKeyboardKey.keyX,
  LogicalKeyboardKey.keyC,
  LogicalKeyboardKey.keyV,
];
const _letras = ['Z', 'X', 'C', 'V'];

/// Each reason with its shortcut, shown on hover over its label.
final ayudaMotivoDevolucion = lineasAyuda(
  [for (final m in MotivoDevolucion.values) m.etiqueta],
  [for (final l in _letras) 'Alt+$l'],
).join('\n');

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
          for (final m in MotivoDevolucion.values)
            ChoiceChip(
              label: Text(m.etiqueta),
              selected: m == motivo,
              showCheckmark: false,
              onSelected: (_) => onMotivo(m),
            ),
        ],
      ),
    );
  }
}
