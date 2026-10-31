import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';
import 'package:inventario/features/salidas/domain/venta.dart';

/// What happens to goods a customer brings back.
enum DestinoDevolucion {
  stock('Vuelve al stock', 'Está bien, se puede vender'),
  merma('Va a merma', 'Vino dañado; no vuelve al stock');

  const DestinoDevolucion(this.etiqueta, this.detalle);

  final String etiqueta;
  final String detalle;
}

/// The returns already made from [venta].
Iterable<Movimiento> devolucionesDe(
  Movimiento venta,
  List<Movimiento> movimientos,
) => movimientos.where(
  (m) => m.tipo == TipoMovimiento.devolucionCliente && m.origenId == venta.id,
);

/// How much of [venta] customers already brought back, scaled like it.
int yaDevuelto(Movimiento venta, List<Movimiento> movimientos) =>
    devolucionesDe(
      venta,
      movimientos,
    ).fold(0, (total, m) => total + m.cantidad);

/// The most that can still come back from [venta].
int devolvible(Movimiento venta, List<Movimiento> movimientos) =>
    venta.anulada ? 0 : venta.cantidad - yaDevuelto(venta, movimientos);

/// Ways money can go back to a customer: never through the card terminal.
List<MedioPago> get mediosReembolso =>
    MedioPago.values.where((m) => m != MedioPago.puntoDeVenta).toList();

/// Offered first: how the sale was paid when that was one way that can give
/// money back; else dollar cash.
MedioPago medioSugerido(Venta? pagada) {
  final medios = {
    for (final p in pagada?.pagos ?? const <PagoVenta>[]) p.medio,
  };
  if (medios.length == 1 && mediosReembolso.contains(medios.single)) {
    return medios.single;
  }
  if (medios.length == 1) return MedioPago.efectivoBolivares;
  return MedioPago.efectivoDolares;
}

/// [importe] (dollar hundredths) in [medio]'s currency, at the sale's
/// [tasa]; null for bolívares when the sale kept no rate.
int? reembolsoEnMoneda(int importe, MedioPago medio, int? tasa) =>
    switch (medio.moneda) {
      Moneda.dolares => importe,
      Moneda.bolivares =>
        tasa == null ? null : dividirRedondeando(importe * tasa, 100),
    };

/// The share of the sale's amount handed back for [cantidad]; null when
/// the sale had no price.
int? importeDevuelto(Movimiento venta, int cantidad) =>
    proporcional(venta.importe, cantidad, venta.cantidad);

/// [total] × [parte] / [de], rounded; null without a total.
int? proporcional(int? total, int parte, int de) =>
    total == null || de == 0 ? null : dividirRedondeando(total * parte, de);

/// What is left of [total] after the [previos] parts; null without a total.
int? restante(int? total, Iterable<int?> previos) => total == null
    ? null
    : previos.fold<int>(total, (queda, p) => queda - (p ?? 0));
