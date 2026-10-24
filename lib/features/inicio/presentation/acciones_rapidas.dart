import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/inicio/presentation/accion_rapida.dart';
import 'package:inventario/features/inicio/presentation/boton_accion.dart';

class AccionesRapidas extends StatelessWidget {
  const AccionesRapidas({super.key, required this.onAccion});

  final ValueChanged<AccionRapida> onAccion;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.espaciado.lg,
      children: [
        for (final accion in AccionRapida.values)
          Expanded(
            child: BotonAccion(
              accion: accion,
              onPulsar: () => onAccion(accion),
            ),
          ),
      ],
    );
  }
}
