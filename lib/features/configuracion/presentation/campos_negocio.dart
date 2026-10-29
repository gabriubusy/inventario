import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/rejilla_adaptable.dart';

/// Nombre, RIF, dirección y teléfono; Enter moves on and saves on the last.
class CamposNegocio extends StatelessWidget {
  const CamposNegocio({
    super.key,
    required this.nombre,
    required this.rif,
    required this.direccion,
    required this.telefono,
    required this.onGuardar,
  });

  static const _anchoMinimo = 280.0;

  final TextEditingController nombre;
  final TextEditingController rif;
  final TextEditingController direccion;
  final TextEditingController telefono;
  final VoidCallback onGuardar;

  @override
  Widget build(BuildContext context) {
    return RejillaAdaptable(
      anchoMinimo: _anchoMinimo,
      espacio: context.espaciado.md,
      children: [
        TextField(
          controller: nombre,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        TextField(
          controller: rif,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'RIF'),
        ),
        TextField(
          controller: direccion,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Dirección'),
        ),
        TextField(
          controller: telefono,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onGuardar(),
          decoration: const InputDecoration(labelText: 'Teléfono'),
        ),
      ],
    );
  }
}
