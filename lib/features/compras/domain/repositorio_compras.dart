import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/pago.dart';

/// Purchases with their payments, one aggregate.
abstract interface class RepositorioCompras {
  Future<List<Compra>> obtenerCompras();

  Future<List<Pago>> obtenerPagos();

  /// Stores it and returns it with its new id.
  Future<Compra> crearCompra(Compra compra);

  /// Only to undo a purchase just made; its payments go with it.
  Future<void> borrarCompra(String id);

  Future<Pago> crearPago(Pago pago);

  /// Only to undo a payment just made.
  Future<void> borrarPago(String id);

  Future<void> renombrarProveedor(String anterior, String nuevo);
}
