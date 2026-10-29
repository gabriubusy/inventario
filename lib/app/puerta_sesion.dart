import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/features/ajustes/application/controlador_ajustes.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/application/estado_sesion.dart';
import 'package:inventario/features/autenticacion/presentation/dialogo_cambiar_pin.dart';
import 'package:inventario/features/autenticacion/presentation/pantalla_inicio_sesion.dart';
import 'package:inventario/features/caja/application/controlador_caja.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/configuracion/application/controlador_negocio.dart';
import 'package:inventario/features/conteo/application/controlador_conteo.dart';
import 'package:inventario/features/devoluciones_proveedor/application/controlador_devoluciones_proveedor.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/inicio/presentation/pantalla_inicio.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/productos/application/controlador_ajuste_precios.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/reportes/data/exportador_archivos.dart';
import 'package:inventario/features/respaldo/application/controlador_respaldo.dart';
import 'package:inventario/features/salidas/application/controlador_devoluciones.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';

/// Shows the PIN screen until a session is open.
class PuertaSesion extends StatelessWidget {
  const PuertaSesion({
    super.key,
    required this.controladorSesion,
    required this.controladorExistencias,
    required this.controladorProveedores,
    required this.controladorEntradas,
    required this.controladorSalidas,
    required this.controladorIncidencias,
    required this.controladorMovimientos,
    required this.controladorCompras,
    required this.controladorGastos,
    required this.controladorCaja,
    required this.controladorAjustes,
    required this.controladorConteo,
    required this.controladorDevoluciones,
    this.controladorDevolucionesProveedor,
    required this.controladorListaProductos,
    required this.controladorTasa,
    required this.gestorFotos,
    this.controladorNegocio,
    this.controladorRespaldo,
    this.controladorAjustePrecios,
  });

  final ControladorSesion controladorSesion;
  final ControladorExistencias controladorExistencias;
  final ControladorProveedores controladorProveedores;
  final ControladorEntradas controladorEntradas;
  final ControladorSalidas controladorSalidas;
  final ControladorIncidencias controladorIncidencias;
  final ControladorMovimientos controladorMovimientos;
  final ControladorCompras controladorCompras;
  final ControladorGastos controladorGastos;
  final ControladorCaja controladorCaja;
  final ControladorAjustes controladorAjustes;
  final ControladorConteo controladorConteo;
  final ControladorDevoluciones controladorDevoluciones;
  final ControladorDevolucionesProveedor? controladorDevolucionesProveedor;
  final ControladorListaProductos controladorListaProductos;
  final ControladorTasa controladorTasa;
  final GestorFotos gestorFotos;
  final ControladorNegocio? controladorNegocio;
  final ControladorRespaldo? controladorRespaldo;
  final ControladorAjustePrecios? controladorAjustePrecios;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controladorSesion,
      builder: (context, _) => switch (controladorSesion.estado) {
        SesionAbierta() => PantallaInicio(
          controlador: controladorExistencias,
          proveedores: controladorProveedores,
          entradas: controladorEntradas,
          salidas: controladorSalidas,
          incidencias: controladorIncidencias,
          movimientos: controladorMovimientos,
          compras: controladorCompras,
          gastos: controladorGastos,
          caja: controladorCaja,
          ajustes: controladorAjustes,
          conteo: controladorConteo,
          devoluciones: controladorDevoluciones,
          devolucionesProveedor: controladorDevolucionesProveedor,
          listaProductos: controladorListaProductos,
          tasa: controladorTasa,
          fotos: gestorFotos,
          onBloquear: controladorSesion.cerrarSesion,
          onCambiarPin: () =>
              unawaited(mostrarDialogoCambiarPin(context, controladorSesion)),
          negocio: controladorNegocio,
          respaldo: controladorRespaldo,
          ajustePrecios: controladorAjustePrecios,
          exportador: ExportadorArchivos(
            encabezado: () => controladorNegocio?.datos.encabezado ?? '',
          ),
        ),
        SesionCerrada() || IniciandoSesion() => PantallaInicioSesion(
          controlador: controladorSesion,
        ),
      },
    );
  }
}
