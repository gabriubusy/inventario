import 'package:flutter/material.dart';

/// The shortcut of an action ("F1", "Ctrl+N") as quiet text next to it.
/// No keycap box: the user found boxes looked cheap.
class TeclaAtajo extends StatelessWidget {
  const TeclaAtajo(this.texto, {super.key, required this.color});

  static const _opacidad = 0.75;

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color.withValues(alpha: _opacidad),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
