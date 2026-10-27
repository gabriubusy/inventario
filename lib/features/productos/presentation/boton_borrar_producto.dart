import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/dialogo_confirmar.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// "Borrar producto · Alt+Supr" in the edit window. Asks first, then
/// removes the product and its photo and closes the window.
class BotonBorrarProducto extends StatelessWidget {
  const BotonBorrarProducto({
    super.key,
    required this.producto,
    required this.controlador,
    required this.fotos,
  });

  static const atajo = SingleActivator(LogicalKeyboardKey.delete, alt: true);

  final Producto producto;
  final ControladorExistencias controlador;
  final GestorFotos fotos;

  String get _mensaje {
    final existencias = producto.tieneExistencias
        ? 'Todavía hay ${textoStock(producto)}, que dejará de contarse. '
        : '';
    return '$existencias'
        'Las ventas y entradas ya registradas siguen en el historial.';
  }

  Future<void> _borrar(BuildContext context) async {
    final navegador = Navigator.of(context);
    final mensajero = ScaffoldMessenger.of(context);
    final si = await confirmar(
      context,
      titulo: '¿Borrar «${producto.nombre}»?',
      mensaje: _mensaje,
      accion: 'Borrar producto',
    );
    if (!si) return;
    await controlador.borrarProducto(producto.id);
    await fotos.borrar(producto.imagenId);
    navegador.pop();
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Producto borrado · ${producto.nombre}')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.coloresEstado.textoAgotado;
    return AtajosDeTeclado(
      atajos: {atajo: () => unawaited(_borrar(context))},
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => unawaited(_borrar(context)),
          style: TextButton.styleFrom(foregroundColor: color),
          icon: const Icon(Icons.delete_outline),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: context.espaciado.sm,
            children: [
              const Text('Borrar producto'),
              TeclaAtajo('Alt+Supr', color: color),
            ],
          ),
        ),
      ),
    );
  }
}
