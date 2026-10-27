import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

/// One product and brand on a supplier's invoice; already validated.
class LineaCompra {
  const LineaCompra({
    required this.productoId,
    required this.producto,
    required this.forma,
    required this.marca,
    this.piezas = 0,
    required this.cantidad,
    required this.costo,
  });

  final String productoId;

  /// Name and way of counting when bought, to show the invoice later.
  final String producto;
  final FormaConteo forma;
  final String marca;

  /// Whole pieces received; 0 for products not counted in pieces.
  final int piezas;

  /// Scaled by the product's unit, like [LoteMarca.cantidad].
  final int cantidad;

  /// Dollar hundredths per kg, l or und.
  final int costo;

  /// Cost × quantity, in dollar hundredths.
  int get subtotal =>
      dividirRedondeando(costo * cantidad, forma.unidad.fraccionesPorUnidad);

  @override
  bool operator ==(Object other) =>
      other is LineaCompra &&
      other.productoId == productoId &&
      other.producto == producto &&
      other.forma == forma &&
      other.marca == marca &&
      other.piezas == piezas &&
      other.cantidad == cantidad &&
      other.costo == costo;

  @override
  int get hashCode =>
      Object.hash(productoId, producto, forma, marca, piezas, cantidad, costo);
}
