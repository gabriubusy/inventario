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

/// Opens the same window filled with [producto]; it closes on save and
/// [alEditar] gets the product before and after, for undo.
Future<void> mostrarDialogoEditarProducto(
  BuildContext context,
  ControladorExistencias controlador, {
  required Producto producto,
  required GestorFotos fotos,
  required void Function(Producto anterior, Producto guardado) alEditar,
  List<String> proveedores = const [],
  int? Function(int dolares)? aBolivares,
  ElegirImagen elegirImagen = elegirImagenDelEquipo,
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoNuevoProducto(
    controlador: controlador,
    fotos: fotos,
    producto: producto,
    alEditar: alEditar,
    proveedores: proveedores,
    aBolivares: aBolivares,
    elegirImagen: elegirImagen,
  ),
);

/// The product window: empty creates (Ctrl+Enter keeps it open for the
/// next one), with [producto] it edits.
class DialogoNuevoProducto extends StatelessWidget {
  const DialogoNuevoProducto({
    super.key,
    required this.controlador,
    required this.fotos,
    this.producto,
    this.alEditar,
    this.proveedores = const [],
    this.aBolivares,
    this.nombreInicial = '',
    this.elegirImagen = elegirImagenDelEquipo,
  });

  static const _ancho = 760.0;

  final ControladorExistencias controlador;
  final GestorFotos fotos;

  /// Null to create a new product.
  final Producto? producto;
  final void Function(Producto anterior, Producto guardado)? alEditar;

  final List<String> proveedores;
  final int? Function(int dolares)? aBolivares;
  final String nombreInicial;
  final ElegirImagen elegirImagen;

  void _guardado(
    BuildContext context,
    Producto guardado, {
    required bool otro,
  }) {
    final anterior = producto;
    if (anterior != null) {
      Navigator.of(context).pop();
      alEditar?.call(anterior, guardado);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Producto creado · ${guardado.nombre}')),
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
              EncabezadoDialogo(
                titulo: producto == null ? 'Nuevo producto' : 'Editar producto',
              ),
              FormularioProducto(
                controlador: controlador,
                fotos: fotos,
                producto: producto,
                proveedores: proveedores,
                aBolivares: aBolivares,
                nombreInicial: nombreInicial,
                elegirImagen: elegirImagen,
                alGuardar: (guardado, {required otro}) =>
                    _guardado(context, guardado, otro: otro),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
