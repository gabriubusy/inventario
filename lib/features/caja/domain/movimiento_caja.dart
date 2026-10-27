import 'package:inventario/core/medio_pago.dart';

/// What moved money in or out of the till.
enum TipoMovimientoCaja {
  apertura('Apertura'),
  venta('Venta'),
  devolucion('Devolución'),
  gasto('Gasto'),
  ingreso('Ingreso'),
  proveedor('Proveedor');

  const TipoMovimientoCaja(this.etiqueta);

  final String etiqueta;
}

/// One line of the till's day. A mixed payment touches several medios,
/// so the amounts go per medio, signed: positive comes in.
class MovimientoCaja {
  const MovimientoCaja({
    required this.fecha,
    required this.tipo,
    required this.detalle,
    required this.montos,
  });

  final DateTime fecha;
  final TipoMovimientoCaja tipo;
  final String detalle;

  /// Hundredths of each medio's currency.
  final Map<MedioPago, int> montos;

  @override
  bool operator ==(Object other) =>
      other is MovimientoCaja &&
      other.fecha == fecha &&
      other.tipo == tipo &&
      other.detalle == detalle &&
      other.montos.length == montos.length &&
      other.montos.entries.every((e) => montos[e.key] == e.value);

  @override
  int get hashCode => Object.hash(
    fecha,
    tipo,
    detalle,
    Object.hashAllUnordered(montos.entries.map((e) => (e.key, e.value))),
  );
}
