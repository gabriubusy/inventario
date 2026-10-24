import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/presentation/buscador_productos.dart';
import 'package:inventario/features/productos/presentation/filtro_categorias.dart';

class CabeceraExistencias extends StatelessWidget {
  const CabeceraExistencias({
    super.key,
    required this.controlador,
    required this.focoBusqueda,
  });

  static const _anchoBuscador = 340.0;

  final ControladorExistencias controlador;
  final FocusNode focoBusqueda;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: espaciado.lg,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Existencias',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              width: _anchoBuscador,
              child: BuscadorProductos(
                controlador: controlador,
                focusNode: focoBusqueda,
              ),
            ),
          ],
        ),
        FiltroCategorias(controlador: controlador),
      ],
    );
  }
}
