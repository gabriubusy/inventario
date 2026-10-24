import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

class AvisoError extends StatelessWidget {
  const AvisoError(this.mensaje, {super.key});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colores.errorContainer,
          borderRadius: BorderRadius.circular(espaciado.sm),
        ),
        child: Padding(
          padding: EdgeInsets.all(espaciado.md),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: colores.onErrorContainer),
              SizedBox(width: espaciado.sm),
              Expanded(
                child: Text(
                  mensaje,
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: colores.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
