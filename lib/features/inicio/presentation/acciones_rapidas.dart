import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/rejilla_adaptable.dart';
import 'package:inventario/features/inicio/presentation/accion_rapida.dart';
import 'package:inventario/features/inicio/presentation/boton_accion.dart';

class AccionesRapidas extends StatelessWidget {
  const AccionesRapidas({super.key, required this.onAccion});

  /// Room for "Registrar entrada" and its key without cutting it.
  static const _anchoMinimo = 250.0;

  final ValueChanged<AccionRapida> onAccion;

  @override
  Widget build(BuildContext context) {
    return RejillaAdaptable(
      anchoMinimo: _anchoMinimo,
      espacio: context.espaciado.lg,
      children: [
        for (final accion in AccionRapida.values)
          BotonAccion(accion: accion, onPulsar: () => onAccion(accion)),
      ],
    );
  }
}
