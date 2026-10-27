import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/core/transacciones.dart';

/// Repository calls made inside join the same SQLite transaction (Drift
/// tracks it per zone), so a failure halfway rolls every write back.
class TransaccionesDrift implements Transacciones {
  const TransaccionesDrift(this._db);

  final BaseDatos _db;

  @override
  Future<T> enUna<T>(Future<T> Function() escrituras) =>
      _db.transaction(escrituras);
}
