import 'package:flutter/material.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/elegir_imagen.dart';
import 'package:inventario/features/productos/presentation/formulario_producto.dart';

Future<void> mostrarDialogoNuevoProducto(
  BuildContext context,
  ControladorExistencias controlador, {
  required GestorFotos fotos,
  List<String> proveedores = const [],
  int? Function(int dolares)? aBolivares,
  String nombreInicial = '',
  ElegirImagen elegirImagen = elegirImagenDelEquipo,
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoNuevoProducto(
    controlador: controlador,
    fotos: fotos,
    proveedores: proveedores,
    aBolivares: aBolivares,
    nombreInicial: nombreInicial,
    elegirImagen: elegirImagen,
  ),
);

/// Quick product creation; Ctrl+Enter keeps it open for the next one.
class DialogoNuevoProducto extends StatelessWidget {
  const DialogoNuevoProducto({
    super.key,
    required this.controlador,
    required this.fotos,
    this.proveedores = const [],
    this.aBolivares,
    this.nombreInicial = '',
    this.elegirImagen = elegirImagenDelEquipo,
  });

  static const _ancho = 760.0;

  final ControladorExistencias controlador;
  final GestorFotos fotos;
  final List<String> proveedores;
  final int? Function(int dolares)? aBolivares;
  final String nombreInicial;
  final ElegirImagen elegirImagen;

  void _creado(BuildContext context, Producto producto, {required bool otro}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Producto creado · ${producto.nombre}')),
      );
    if (!otro) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _ancho),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(espaciado.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: espaciado.lg,
            children: [
              const EncabezadoDialogo(titulo: 'Nuevo producto'),
              FormularioProducto(
                controlador: controlador,
                fotos: fotos,
                proveedores: proveedores,
                aBolivares: aBolivares,
                nombreInicial: nombreInicial,
                elegirImagen: elegirImagen,
                alGuardar: (producto, {required otro}) =>
                    _creado(context, producto, otro: otro),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
