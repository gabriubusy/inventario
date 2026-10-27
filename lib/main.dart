import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/app/app.dart';
import 'package:inventario/app/base_datos/abrir_base_datos.dart';
import 'package:inventario/app/base_datos/sembrar_ejemplos.dart';
import 'package:inventario/app/base_datos/transacciones_drift.dart';
import 'package:inventario/features/ajustes/application/controlador_ajustes.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/data/almacen_sesion_preferencias.dart';
import 'package:inventario/features/autenticacion/data/cuentas_de_desarrollo.dart';
import 'package:inventario/features/autenticacion/data/repositorio_autenticacion_preferencias.dart';
import 'package:inventario/features/conteo/application/controlador_conteo.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/data/repositorio_incidencias_drift.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_drift.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/data/almacen_imagenes_local.dart';
import 'package:inventario/features/productos/data/repositorio_productos_drift.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/data/repositorio_proveedores_drift.dart';
import 'package:inventario/features/salidas/application/controlador_devoluciones.dart';
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
  final baseDatos = abrirBaseDatos();
  final productos = RepositorioProductosDrift(baseDatos);
  final proveedores = RepositorioProveedoresDrift(baseDatos);
  final incidencias = RepositorioIncidenciasDrift(baseDatos);
  final movimientos = RepositorioMovimientosDrift(baseDatos);
  final transacciones = TransaccionesDrift(baseDatos);
  await sembrarEjemplos(
    productos: productos,
    proveedores: proveedores,
    incidencias: incidencias,
    movimientos: movimientos,
  );
  final controladorExistencias = ControladorExistencias(productos);
  final controladorMovimientos = ControladorMovimientos(movimientos);
  final controladorIncidencias = ControladorIncidencias(
    incidencias,
    controladorExistencias,
    movimientos: controladorMovimientos,
    transacciones: transacciones,
  );
  final controladorProveedores = ControladorProveedores(
    proveedores,
    controladorExistencias,
    alRenombrar: [controladorIncidencias.renombrarProveedor],
  );
  final controladorEntradas = ControladorEntradas(
    controladorExistencias,
    movimientos: controladorMovimientos,
    transacciones: transacciones,
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
        tasaDeHoy: () => controladorTasa.tasaDeHoy,
        transacciones: transacciones,
      ),
      controladorIncidencias: controladorIncidencias,
      controladorMovimientos: controladorMovimientos,
      controladorAjustes: ControladorAjustes(
        controladorExistencias,
        movimientos: controladorMovimientos,
        transacciones: transacciones,
      ),
      controladorConteo: ControladorConteo(
        controladorExistencias,
        movimientos: controladorMovimientos,
        transacciones: transacciones,
      ),
      controladorDevoluciones: ControladorDevoluciones(
        controladorExistencias,
        controladorMovimientos,
        transacciones: transacciones,
      ),
      controladorListaProductos: ControladorListaProductos(
        controladorExistencias,
      ),
      controladorTasa: controladorTasa,
      gestorFotos: gestorFotos,
    ),
  );
}
