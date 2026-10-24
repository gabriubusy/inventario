import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';

class EncabezadoInicioSesion extends StatelessWidget {
  const EncabezadoInicioSesion({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colores.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(espaciado.lg),
            child: Icon(
              Icons.storefront_outlined,
              size: espaciado.xxl,
              color: colores.onPrimaryContainer,
            ),
          ),
        ),
        SizedBox(height: espaciado.lg),
        Text(
          'Introduce tu PIN',
          style: tema.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: espaciado.xs),
        Text(
          '${Pin.longitud} dígitos',
          style: tema.textTheme.bodyMedium?.copyWith(
            color: colores.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
