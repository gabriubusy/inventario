import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

/// "Efectivo $ · Alt+A" per option, for an [ConEtiqueta.ayuda].
List<String> lineasAyuda(List<String> opciones, List<String> teclas) => [
  for (final (i, o) in opciones.indexed)
    if (i < teclas.length) '$o · ${teclas[i]}' else o,
];

/// A small label above a group of controls that has no field label of its own.
/// With [ayuda], hovering the label explains the options and their shortcuts.
class ConEtiqueta extends StatelessWidget {
  const ConEtiqueta({
    super.key,
    required this.etiqueta,
    required this.child,
    this.ayuda,
  });

  static const _tamanoAyuda = 16.0;

  final String etiqueta;
  final String? ayuda;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final ayuda = this.ayuda;
    final texto = Text(etiqueta, style: tema.textTheme.labelLarge);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: espaciado.xs,
      children: [
        if (ayuda == null)
          texto
        else
          Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: ayuda,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: espaciado.xs,
                children: [
                  texto,
                  Icon(
                    Icons.help_outline,
                    size: _tamanoAyuda,
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        child,
      ],
    );
  }
}
