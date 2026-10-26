import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/app/app.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/data/almacen_sesion_preferencias.dart';
import 'package:inventario/features/autenticacion/data/cuentas_de_desarrollo.dart';
import 'package:inventario/features/autenticacion/data/repositorio_autenticacion_en_memoria.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/data/almacen_imagenes_local.dart';
import 'package:inventario/features/productos/data/productos_de_ejemplo.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/data/proveedores_de_ejemplo.dart';
import 'package:inventario/features/proveedores/data/repositorio_proveedores_en_memoria.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/data/almacen_tasa_preferencias.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controladorSesion = ControladorSesion(
    RepositorioAutenticacionEnMemoria(cuentaDeDesarrollo),
    AlmacenSesionPreferencias(),
  );
  // Restored before the first frame so the PIN screen doesn't flash.
  await controladorSesion.restaurar();
  final controladorExistencias = ControladorExistencias(
    RepositorioProductosEnMemoria(productosDeEjemplo),
  );
  final controladorProveedores = ControladorProveedores(
    RepositorioProveedoresEnMemoria(proveedoresDeEjemplo),
    controladorExistencias,
  );
  final controladorEntradas = ControladorEntradas(controladorExistencias);
  final controladorTasa = ControladorTasa(AlmacenTasaPreferencias());
  final gestorFotos = GestorFotos(await crearAlmacenImagenesLocal());
  unawaited(controladorExistencias.cargar());
  unawaited(controladorProveedores.cargar());
  unawaited(controladorTasa.cargar());
  runApp(
    InventarioApp(
      controladorSesion: controladorSesion,
      controladorExistencias: controladorExistencias,
      controladorProveedores: controladorProveedores,
      controladorEntradas: controladorEntradas,
      controladorListaProductos: ControladorListaProductos(
        controladorExistencias,
      ),
      controladorTasa: controladorTasa,
      gestorFotos: gestorFotos,
    ),
  );
}
