import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/categoria.dart';

class FiltroCategorias extends StatelessWidget {
  const FiltroCategorias({super.key, required this.controlador});

  final ControladorExistencias controlador;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final elegida = controlador.categoria;
    return Wrap(
      spacing: espaciado.sm,
      runSpacing: espaciado.sm,
      children: [
        ChoiceChip(
          label: const Text('Todos'),
          selected: elegida == null,
          onSelected: (_) => controlador.elegirCategoria(null),
        ),
        for (final categoria in Categoria.values)
          ChoiceChip(
            label: Text(categoria.etiqueta),
            selected: elegida == categoria,
            onSelected: (_) => controlador.elegirCategoria(categoria),
          ),
      ],
    );
  }
}
