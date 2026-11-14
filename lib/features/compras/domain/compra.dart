import 'package:inventario/core/listas.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/compras/domain/estado_pedido.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';

/// A supplier's order: what was asked for, what it costs and how it is
/// paid. What really arrived is confirmed later, line by line.
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
    this.recibidaEl,
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

  /// When its arrival was last confirmed; null while nothing arrived.
  final DateTime? recibidaEl;

  bool get aCredito => vence != null;

  /// In dollar hundredths: always what was ordered, because that is what
  /// the invoice charges even if the supplier brought something else.
  int get total => lineas.fold(0, (suma, l) => suma + l.subtotal);

  /// What already arrived, at the invoice's cost.
  int get recibido => lineas.fold(0, (suma, l) => suma + l.subtotalRecibido);

  /// What is still on the way, at the invoice's cost.
  int get porRecibir =>
      lineas.fold(0, (suma, l) => suma + (l.recibida ? 0 : l.subtotal));

  /// More (or less) than the invoice, in dollar hundredths.
  int get diferencia => lineas.fold(
    0,
    (suma, l) => suma + (l.recibida ? l.subtotalRecibido - l.subtotal : 0),
  );

  int get lineasConDiferencia => lineas.where((l) => l.tieneDiferencia).length;

  EstadoPedido get estado {
    final recibidas = lineas.where((l) => l.recibida).length;
    if (recibidas == 0) return EstadoPedido.pendiente;
    if (recibidas < lineas.length) return EstadoPedido.parcial;
    return lineasConDiferencia > 0
        ? EstadoPedido.conDiferencias
        : EstadoPedido.recibido;
  }

  Compra conId(String id) => _con(id: id);

  Compra conProveedor(String proveedor) => _con(proveedor: proveedor);

  /// What arrived of each line and when; [recibidaEl] null undoes it.
  Compra conRecepcion(List<LineaCompra> lineas, {required DateTime? cuando}) =>
      Compra(
        id: id,
        fecha: fecha,
        proveedor: proveedor,
        factura: factura,
        lineas: lineas,
        vence: vence,
        medio: medio,
        tasa: tasa,
        recibidaEl: cuando,
      );

  Compra _con({String? id, String? proveedor}) => Compra(
    id: id ?? this.id,
    fecha: fecha,
    proveedor: proveedor ?? this.proveedor,
    factura: factura,
    lineas: lineas,
    vence: vence,
    medio: medio,
    tasa: tasa,
    recibidaEl: recibidaEl,
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
      other.tasa == tasa &&
      other.recibidaEl == recibidaEl;

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
    recibidaEl,
  );
}
