import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';

/// What happens to goods a customer brings back.
enum DestinoDevolucion {
  stock('Vuelve al stock', 'Está bien, se puede vender'),
  merma('Va a merma', 'Vino dañado; no vuelve al stock');

  const DestinoDevolucion(this.etiqueta, this.detalle);

  final String etiqueta;
  final String detalle;
}

/// How much of [venta] customers already brought back, scaled like it.
int yaDevuelto(Movimiento venta, List<Movimiento> movimientos) => movimientos
    .where(
      (m) =>
          m.tipo == TipoMovimiento.devolucionCliente && m.origenId == venta.id,
    )
    .fold(0, (total, m) => total + m.cantidad);

/// The most that can still come back from [venta].
int devolvible(Movimiento venta, List<Movimiento> movimientos) =>
    venta.anulada ? 0 : venta.cantidad - yaDevuelto(venta, movimientos);

/// The share of the sale's amount handed back for [cantidad]; null when
/// the sale had no price.
int? importeDevuelto(Movimiento venta, int cantidad) {
  final importe = venta.importe;
  if (importe == null || venta.cantidad == 0) return null;
  return dividirRedondeando(importe * cantidad, venta.cantidad);
}
