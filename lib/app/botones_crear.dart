import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';

/// Main save button plus, when creating, "Crear y otro".
class BotonesCrear extends StatelessWidget {
  const BotonesCrear({
    super.key,
    required this.guardando,
    required this.onCrear,
    this.onCrearOtro,
    this.etiqueta = 'Crear',
    this.etiquetaOtro = 'Crear y otro',
    this.atajo = 'Enter',
  });

  static const _alto = Size.fromHeight(52);

  final bool guardando;
  final VoidCallback onCrear;
  final VoidCallback? onCrearOtro;
  final String etiqueta;
  final String etiquetaOtro;

  /// Shortcut shown on the main button.
  final String atajo;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final onCrearOtro = this.onCrearOtro;
    return Row(
      spacing: context.espaciado.md,
      children: [
        Expanded(
          flex: 3,
          child: FilledButton(
            onPressed: guardando ? null : onCrear,
            style: FilledButton.styleFrom(minimumSize: _alto),
            child: _Etiqueta(etiqueta, atajo, color: colores.onPrimary),
          ),
        ),
        if (onCrearOtro != null)
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: guardando ? null : onCrearOtro,
              style: OutlinedButton.styleFrom(minimumSize: _alto),
              child: _Etiqueta(
                etiquetaOtro,
                'Ctrl+Enter',
                color: colores.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// Shrinks instead of overflowing when the window is narrow.
class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto, this.atajo, {required this.color});

  final String texto;
  final String atajo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.espaciado.sm,
        children: [
          Text(texto),
          TeclaAtajo(atajo, color: color),
        ],
      ),
    );
  }
}
