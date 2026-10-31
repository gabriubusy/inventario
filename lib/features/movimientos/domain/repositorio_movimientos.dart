import 'package:inventario/features/movimientos/domain/movimiento.dart';

abstract interface class RepositorioMovimientos {
  Future<List<Movimiento>> obtenerTodos();

  /// Stores it and returns it with its new id.
  Future<Movimiento> anotar(Movimiento movimiento);

  /// Only to undo the sale or entry it records.
  Future<void> quitar(String id);

  /// Marks a sale as cancelled [el] that moment; it is kept, crossed out.
  Future<void> anular(String id, {DateTime? el});

  /// So a cancelled or returned sale goes back to the renamed brand lot.
  Future<void> renombrarProveedor(String anterior, String nuevo);
}
