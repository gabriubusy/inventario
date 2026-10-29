import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/features/respaldo/data/gestor_respaldos_archivos.dart';
import 'package:inventario/features/respaldo/domain/gestor_respaldos.dart';
import 'package:path_provider/path_provider.dart';

Future<GestorRespaldos> crearGestorRespaldosLocal(BaseDatos db) async =>
    GestorRespaldosArchivos(db, await getApplicationSupportDirectory());

/// Puts a prepared backup in place; call before the database opens.
Future<bool> aplicarRestauracionPendiente() async =>
    GestorRespaldosArchivos.aplicarRestauracionPendiente(
      await getApplicationSupportDirectory(),
    );
