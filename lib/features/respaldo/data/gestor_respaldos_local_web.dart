import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/features/respaldo/data/gestor_respaldos_no_disponible.dart';
import 'package:inventario/features/respaldo/domain/gestor_respaldos.dart';

/// The browser keeps its data in its own storage: nothing to copy.
Future<GestorRespaldos> crearGestorRespaldosLocal(BaseDatos db) async =>
    const GestorRespaldosNoDisponible();

Future<bool> aplicarRestauracionPendiente() async => false;
