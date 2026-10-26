import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/elegir_imagen.dart';
import 'package:inventario/features/productos/presentation/formulario_producto.dart';

/// The chosen product, ready to edit with the same form used to create it.
class PanelProducto extends StatelessWidget {
  const PanelProducto({
    super.key,
    required this.producto,
    required this.existencias,
    required this.fotos,
    required this.focoNombre,
    required this.alGuardar,
    this.proveedores = const [],
    this.aBolivares,
    this.elegirImagen = elegirImagenDelEquipo,
  });

  final Producto producto;
  final ControladorExistencias existencias;
  final GestorFotos fotos;
  final FocusNode focoNombre;

  /// Receives the product before and after the save, for undo.
  final void Function(Producto anterior, Producto guardado) alGuardar;

  final List<String> proveedores;
  final int? Function(int dolares)? aBolivares;
  final ElegirImagen elegirImagen;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    return Card(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(espaciado.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: espaciado.lg,
          children: [
            Text(
              'Editar producto',
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            // Keyed by value: after a save or an undo the form starts over
            // from what is stored, instead of keeping stale text.
            FormularioProducto(
              key: ValueKey(producto),
              controlador: existencias,
              fotos: fotos,
              producto: producto,
              proveedores: proveedores,
              aBolivares: aBolivares,
              elegirImagen: elegirImagen,
              focoNombre: focoNombre,
              alGuardar: (guardado, {required otro}) =>
                  alGuardar(producto, guardado),
            ),
          ],
        ),
      ),
    );
  }
}
