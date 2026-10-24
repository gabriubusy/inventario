import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/app/app.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/data/almacen_sesion_preferencias.dart';
import 'package:inventario/features/autenticacion/data/cuentas_de_desarrollo.dart';
import 'package:inventario/features/autenticacion/data/repositorio_autenticacion_en_memoria.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/productos_de_ejemplo.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controladorSesion = ControladorSesion(
    RepositorioAutenticacionEnMemoria(cuentaDeDesarrollo),
    AlmacenSesionPreferencias(),
  );
  // Restored before the first frame so the PIN screen doesn't flash.
  await controladorSesion.restaurar();
  final controladorExistencias = ControladorExistencias(
    const RepositorioProductosEnMemoria(productosDeEjemplo),
  );
  unawaited(controladorExistencias.cargar());
  runApp(
    InventarioApp(
      controladorSesion: controladorSesion,
      controladorExistencias: controladorExistencias,
    ),
  );
}
