import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/app/app.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/data/almacen_sesion_preferencias.dart';
import 'package:inventario/features/autenticacion/data/cuentas_de_desarrollo.dart';
import 'package:inventario/features/autenticacion/data/repositorio_autenticacion_preferencias.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/data/incidencias_de_ejemplo.dart';
import 'package:inventario/features/incidencias/data/repositorio_incidencias_en_memoria.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/movimientos_de_ejemplo.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/data/almacen_imagenes_local.dart';
import 'package:inventario/features/productos/data/productos_de_ejemplo.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/data/proveedores_de_ejemplo.dart';
import 'package:inventario/features/proveedores/data/repositorio_proveedores_en_memoria.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/data/almacen_tasa_preferencias.dart';
import 'package:inventario/features/tasa/data/fuente_tasa_dolar_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controladorSesion = ControladorSesion(
    RepositorioAutenticacionPreferencias(
      usuario: cuentaDeDesarrollo.usuario,
      pinInicial: cuentaDeDesarrollo.pin,
    ),
    AlmacenSesionPreferencias(),
  );
  // Restored before the first frame so the PIN screen doesn't flash.
  await controladorSesion.restaurar();
  final controladorExistencias = ControladorExistencias(
    RepositorioProductosEnMemoria(productosDeEjemplo),
  );
  final controladorIncidencias = ControladorIncidencias(
    RepositorioIncidenciasEnMemoria(incidenciasDeEjemplo(DateTime.now())),
    controladorExistencias,
  );
  final controladorProveedores = ControladorProveedores(
    RepositorioProveedoresEnMemoria(proveedoresDeEjemplo),
    controladorExistencias,
    alRenombrar: [controladorIncidencias.renombrarProveedor],
  );
  final controladorMovimientos = ControladorMovimientos(
    RepositorioMovimientosEnMemoria(movimientosDeEjemplo(DateTime.now())),
  );
  final controladorEntradas = ControladorEntradas(
    controladorExistencias,
    movimientos: controladorMovimientos,
  );
  final controladorTasa = ControladorTasa(
    AlmacenTasaPreferencias(),
    fuente: FuenteTasaDolarApi(),
  );
  final gestorFotos = GestorFotos(await crearAlmacenImagenesLocal());
  unawaited(controladorExistencias.cargar());
  unawaited(controladorProveedores.cargar());
  unawaited(controladorIncidencias.cargar());
  unawaited(controladorMovimientos.cargar());
  // Today's BCV rate is fetched once, after reading the saved one.
  unawaited(
    controladorTasa.cargar().then(
      (_) => controladorTasa.actualizarDesdeInternet(),
    ),
  );
  runApp(
    InventarioApp(
      controladorSesion: controladorSesion,
      controladorExistencias: controladorExistencias,
      controladorProveedores: controladorProveedores,
      controladorEntradas: controladorEntradas,
      controladorSalidas: ControladorSalidas(
        controladorExistencias,
        movimientos: controladorMovimientos,
      ),
      controladorIncidencias: controladorIncidencias,
      controladorMovimientos: controladorMovimientos,
      controladorListaProductos: ControladorListaProductos(
        controladorExistencias,
      ),
      controladorTasa: controladorTasa,
      gestorFotos: gestorFotos,
    ),
  );
}
