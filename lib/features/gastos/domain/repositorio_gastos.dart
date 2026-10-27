import 'package:inventario/features/gastos/domain/gasto.dart';

abstract interface class RepositorioGastos {
  Future<List<Gasto>> obtenerTodos();

  /// Stores it and returns it with its new id.
  Future<Gasto> crear(Gasto gasto);

  /// Only to undo the one just made.
  Future<void> quitar(String id);
}
