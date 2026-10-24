import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';

/// One dot per PIN digit, filled as they are typed.
class IndicadorPin extends StatelessWidget {
  const IndicadorPin({super.key, required this.introducidos});

  final int introducidos;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return Semantics(
      label: '$introducidos de ${Pin.longitud} dígitos',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: espaciado.md,
        children: [
          for (var i = 0; i < Pin.longitud; i++)
            _Punto(lleno: i < introducidos),
        ],
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  const _Punto({required this.lleno});

  final bool lleno;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: context.espaciado.md,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: lleno ? colores.primary : null,
          border: lleno ? null : Border.all(color: colores.outline, width: 1.5),
        ),
      ),
    );
  }
}
