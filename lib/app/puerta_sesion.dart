import 'package:flutter/material.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/application/estado_sesion.dart';
import 'package:inventario/features/autenticacion/presentation/pantalla_inicio_sesion.dart';
import 'package:inventario/features/inicio/presentation/pantalla_inicio.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';

/// Shows the PIN screen until a session is open.
class PuertaSesion extends StatelessWidget {
  const PuertaSesion({
    super.key,
    required this.controladorSesion,
    required this.controladorExistencias,
  });

  final ControladorSesion controladorSesion;
  final ControladorExistencias controladorExistencias;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controladorSesion,
      builder: (context, _) => switch (controladorSesion.estado) {
        SesionAbierta() => PantallaInicio(
          controlador: controladorExistencias,
          onBloquear: controladorSesion.cerrarSesion,
        ),
        SesionCerrada() || IniciandoSesion() => PantallaInicioSesion(
          controlador: controladorSesion,
        ),
      },
    );
  }
}
