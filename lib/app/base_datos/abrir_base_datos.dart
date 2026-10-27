import 'package:drift_flutter/drift_flutter.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:path_provider/path_provider.dart';

/// The shop's data file, `inventario.sqlite` in the app support folder
/// (never under Program Files). In the browser build it lives in the
/// browser's storage, served with web/sqlite3.wasm and web/drift_worker.js.
BaseDatos abrirBaseDatos() => BaseDatos(
  driftDatabase(
    name: 'inventario',
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  ),
);
