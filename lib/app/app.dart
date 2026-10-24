import 'package:flutter/material.dart';
import 'package:inventario/app/puerta_sesion.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';

class InventarioApp extends StatelessWidget {
  const InventarioApp({
    super.key,
    required this.controladorSesion,
    required this.controladorExistencias,
  });

  final ControladorSesion controladorSesion;
  final ControladorExistencias controladorExistencias;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro(),
      home: PuertaSesion(
        controladorSesion: controladorSesion,
        controladorExistencias: controladorExistencias,
      ),
    );
  }
}
