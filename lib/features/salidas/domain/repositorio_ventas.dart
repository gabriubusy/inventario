import 'package:inventario/features/salidas/domain/venta.dart';

abstract interface class RepositorioVentas {
  Future<List<Venta>> obtenerTodas();

  /// Stores it and returns it with its new id.
  Future<Venta> registrar(Venta venta);

  /// Only to undo the sale just made.
  Future<void> quitar(String id);
}
