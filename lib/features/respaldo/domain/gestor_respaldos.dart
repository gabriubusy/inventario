import 'package:inventario/features/respaldo/domain/archivo_respaldo.dart';
import 'package:inventario/features/respaldo/domain/resultado_respaldo.dart';

/// Copies all the shop's data (database and photos) to one file and puts
/// such a file back.
abstract interface class GestorRespaldos {
  /// False in the browser build, which has no file system.
  bool get disponible;

  /// Writes a `.inventario` file into [carpeta], named after [fecha].
  Future<ResultadoRespaldo> respaldar(
    String carpeta, {
    required DateTime fecha,
    String prefijo = 'inventario',
  });

  /// The backups in [carpeta], newest first.
  Future<List<ArchivoRespaldo>> enCarpeta(String carpeta);

  /// Saves a copy of what there is now next to [archivo], then leaves
  /// [archivo] ready to replace everything on the next start.
  Future<ResultadoRespaldo> prepararRestauracion(
    String archivo, {
    required DateTime fecha,
  });

  /// Closes the app so the restore can finish when it opens again.
  void cerrarApp();
}
