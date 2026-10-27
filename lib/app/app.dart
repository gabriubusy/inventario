import 'package:flutter/material.dart';
import 'package:inventario/app/puerta_sesion.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/ajustes/application/controlador_ajustes.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/caja/application/controlador_caja.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/conteo/application/controlador_conteo.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/salidas/application/controlador_devoluciones.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';

class InventarioApp extends StatelessWidget {
  const InventarioApp({
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
    required this.controladorListaProductos,
    required this.controladorTasa,
    required this.gestorFotos,
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
  final ControladorListaProductos controladorListaProductos;
  final ControladorTasa controladorTasa;
  final GestorFotos gestorFotos;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro(),
      home: PuertaSesion(
        controladorSesion: controladorSesion,
        controladorExistencias: controladorExistencias,
        controladorProveedores: controladorProveedores,
        controladorEntradas: controladorEntradas,
        controladorSalidas: controladorSalidas,
        controladorIncidencias: controladorIncidencias,
        controladorMovimientos: controladorMovimientos,
        controladorCompras: controladorCompras,
        controladorGastos: controladorGastos,
        controladorCaja: controladorCaja,
        controladorAjustes: controladorAjustes,
        controladorConteo: controladorConteo,
        controladorDevoluciones: controladorDevoluciones,
        controladorListaProductos: controladorListaProductos,
        controladorTasa: controladorTasa,
        gestorFotos: gestorFotos,
      ),
    );
  }
}
