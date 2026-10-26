import 'package:flutter/material.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/application/estado_sesion.dart';
import 'package:inventario/features/autenticacion/presentation/pantalla_inicio_sesion.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/inicio/presentation/pantalla_inicio.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';

/// Shows the PIN screen until a session is open.
class PuertaSesion extends StatelessWidget {
  const PuertaSesion({
    super.key,
    required this.controladorSesion,
    required this.controladorExistencias,
    required this.controladorProveedores,
    required this.controladorEntradas,
    required this.controladorListaProductos,
    required this.controladorTasa,
    required this.gestorFotos,
  });

  final ControladorSesion controladorSesion;
  final ControladorExistencias controladorExistencias;
  final ControladorProveedores controladorProveedores;
  final ControladorEntradas controladorEntradas;
  final ControladorListaProductos controladorListaProductos;
  final ControladorTasa controladorTasa;
  final GestorFotos gestorFotos;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controladorSesion,
      builder: (context, _) => switch (controladorSesion.estado) {
        SesionAbierta() => PantallaInicio(
          controlador: controladorExistencias,
          proveedores: controladorProveedores,
          entradas: controladorEntradas,
          listaProductos: controladorListaProductos,
          tasa: controladorTasa,
          fotos: gestorFotos,
          onBloquear: controladorSesion.cerrarSesion,
        ),
        SesionCerrada() || IniciandoSesion() => PantallaInicioSesion(
          controlador: controladorSesion,
        ),
      },
    );
  }
}
