import 'package:flutter/material.dart';
import 'package:inventario/app/puerta_sesion.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';

class InventarioApp extends StatelessWidget {
  const InventarioApp({
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
    return MaterialApp(
      title: 'Inventario',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro(),
      home: PuertaSesion(
        controladorSesion: controladorSesion,
        controladorExistencias: controladorExistencias,
        controladorProveedores: controladorProveedores,
        controladorEntradas: controladorEntradas,
        controladorListaProductos: controladorListaProductos,
        controladorTasa: controladorTasa,
        gestorFotos: gestorFotos,
      ),
    );
  }
}
