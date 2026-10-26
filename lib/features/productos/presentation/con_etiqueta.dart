import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

/// A small label above a group of controls that has no field label of its own.
class ConEtiqueta extends StatelessWidget {
  const ConEtiqueta({super.key, required this.etiqueta, required this.child});

  final String etiqueta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.espaciado.xs,
      children: [
        Text(etiqueta, style: Theme.of(context).textTheme.labelLarge),
        child,
      ],
    );
  }
}
