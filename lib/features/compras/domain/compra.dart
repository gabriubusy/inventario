import 'package:inventario/core/listas.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';

/// A supplier's invoice: what came in, what it cost and how it is paid.
class Compra {
  const Compra({
    this.id = '',
    required this.fecha,
    required this.proveedor,
    this.factura = '',
    required this.lineas,
    this.vence,
    this.medio,
    this.tasa,
  });

  /// Empty until the repository stores it.
  final String id;
  final DateTime fecha;

  /// Supplier name, the same link brand lots use.
  final String proveedor;

  /// The supplier's invoice number; empty when there was none.
  final String factura;
  final List<LineaCompra> lineas;

  /// When a purchase on credit must be paid; null when paid on the spot.
  final DateTime? vence;

  /// How a cash purchase was paid; null on credit.
  final MedioPago? medio;

  /// Bs per dollar (hundredths) that day, to show its amount in Bs later.
  final int? tasa;

  bool get aCredito => vence != null;

  /// In dollar hundredths.
  int get total => lineas.fold(0, (suma, l) => suma + l.subtotal);

  Compra conId(String id) => Compra(
    id: id,
    fecha: fecha,
    proveedor: proveedor,
    factura: factura,
    lineas: lineas,
    vence: vence,
    medio: medio,
    tasa: tasa,
  );

  Compra conProveedor(String proveedor) => Compra(
    id: id,
    fecha: fecha,
    proveedor: proveedor,
    factura: factura,
    lineas: lineas,
    vence: vence,
    medio: medio,
    tasa: tasa,
  );

  @override
  bool operator ==(Object other) =>
      other is Compra &&
      other.id == id &&
      other.fecha == fecha &&
      other.proveedor == proveedor &&
      other.factura == factura &&
      listasIguales(other.lineas, lineas) &&
      other.vence == vence &&
      other.medio == medio &&
      other.tasa == tasa;

  @override
  int get hashCode => Object.hash(
    id,
    fecha,
    proveedor,
    factura,
    Object.hashAll(lineas),
    vence,
    medio,
    tasa,
  );
}
