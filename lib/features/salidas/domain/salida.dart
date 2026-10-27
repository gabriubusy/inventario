import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/salidas/domain/modo_venta.dart';

/// Goods sold or dispatched from one brand lot; already validated.
class Salida {
  const Salida({
    required this.marca,
    this.proveedor = '',
    this.modo,
    this.presentacion,
    required this.cantidad,
    this.nota = '',
  });

  final String marca;
  final String proveedor;

  /// Only for products counted in pieces and kilos.
  final ModoVenta? modo;

  /// The pack it was sold in, which sets its price; null when sold in the
  /// product's own unit.
  final Presentacion? presentacion;

  /// Scaled by the product's unit: the piece's weight, or what is sold.
  final int cantidad;

  final String nota;

  /// Whole pieces that go out with it.
  int get piezas => modo == ModoVenta.piezaEntera ? 1 : 0;

  @override
  bool operator ==(Object other) =>
      other is Salida &&
      other.marca == marca &&
      other.proveedor == proveedor &&
      other.modo == modo &&
      other.presentacion == presentacion &&
      other.cantidad == cantidad &&
      other.nota == nota;

  @override
  int get hashCode =>
      Object.hash(marca, proveedor, modo, presentacion, cantidad, nota);
}
