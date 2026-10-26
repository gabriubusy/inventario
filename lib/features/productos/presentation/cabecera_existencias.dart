import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/presentation/buscador_productos.dart';
import 'package:inventario/features/productos/presentation/filtro_categorias.dart';

class CabeceraExistencias extends StatelessWidget {
  const CabeceraExistencias({
    super.key,
    required this.controlador,
    required this.focoBusqueda,
    required this.onNuevoProducto,
  });

  static const _anchoBuscador = 340.0;

  final ControladorExistencias controlador;
  final FocusNode focoBusqueda;
  final VoidCallback onNuevoProducto;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final colores = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: espaciado.lg,
      children: [
        Row(
          spacing: espaciado.md,
          children: [
            Expanded(
              child: Text(
                'Existencias',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onNuevoProducto,
              icon: const Icon(Icons.add),
              label: Row(
                spacing: espaciado.sm,
                children: [
                  const Text('Nuevo producto'),
                  TeclaAtajo('Ctrl+N', color: colores.onSurfaceVariant),
                ],
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
