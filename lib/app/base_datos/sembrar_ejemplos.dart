import 'package:flutter/foundation.dart';
import 'package:inventario/features/incidencias/data/incidencias_de_ejemplo.dart';
import 'package:inventario/features/incidencias/data/repositorio_incidencias_drift.dart';
import 'package:inventario/features/movimientos/data/movimientos_de_ejemplo.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_drift.dart';
import 'package:inventario/features/productos/data/productos_de_ejemplo.dart';
import 'package:inventario/features/productos/data/repositorio_productos_drift.dart';
import 'package:inventario/features/proveedores/data/proveedores_de_ejemplo.dart';
import 'package:inventario/features/proveedores/data/repositorio_proveedores_drift.dart';

/// Fills an empty database with the example shop, only in debug builds:
/// the installed app always starts empty.
Future<void> sembrarEjemplos({
  required RepositorioProductosDrift productos,
  required RepositorioProveedoresDrift proveedores,
  required RepositorioIncidenciasDrift incidencias,
  required RepositorioMovimientosDrift movimientos,
}) async {
  // A test build (--dart-define=EJEMPLOS=true) also gets them, so it is
  // not empty outside debug.
  const ejemplos = kDebugMode || bool.fromEnvironment('EJEMPLOS');
  if (!ejemplos || (await productos.obtenerTodos()).isNotEmpty) return;
  final hoy = DateTime.now();
  await productos.sembrar(productosDeEjemplo);
  await proveedores.sembrar(proveedoresDeEjemplo);
  await incidencias.sembrar(incidenciasDeEjemplo(hoy));
  await movimientos.sembrar(movimientosDeEjemplo(hoy));
}
