import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/caja/domain/caja.dart';
import 'package:inventario/features/caja/domain/movimiento_caja.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/cuenta_por_pagar.dart';
import 'package:inventario/features/compras/domain/pago.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/devolucion_proveedor.dart';
import 'package:inventario/features/gastos/domain/gasto.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/salidas/domain/venta.dart';

/// Everything that moved money while [caja] was open, newest first.
/// Change and refunds go back in cash: dollars when the sale got dollar
/// cash, else bolívares at the sale's rate.
List<MovimientoCaja> movimientosDeCaja({
  required Caja caja,
  List<Venta> ventas = const [],
  List<Movimiento> lineas = const [],
  List<Compra> compras = const [],
  List<Pago> pagos = const [],
  List<Gasto> gastos = const [],
  List<DevolucionProveedor> devolucionesProveedor = const [],
}) {
  final movimientos = <MovimientoCaja>[
    if (caja.fondo.isNotEmpty)
      MovimientoCaja(
        fecha: caja.abierta,
        tipo: TipoMovimientoCaja.apertura,
        detalle: 'Fondo de caja',
        montos: caja.fondo,
      ),
  ];
  final porVenta = {for (final v in ventas) v.id: v};
  for (final venta in ventas) {
    if (!caja.incluye(venta.fecha)) continue;
    final montos = <MedioPago, int>{};
    for (final pago in venta.pagos) {
      montos[pago.medio] = (montos[pago.medio] ?? 0) + pago.monto;
    }
    final pagado = venta.pagos.fold(
      0,
      (suma, p) => suma + p.enDolares(venta.tasa ?? 0),
    );
    final vuelto = pagado - venta.total;
    if (vuelto > 0) _restarEfectivo(montos, vuelto, venta);
    final lineasVenta = lineas.where((l) => l.ventaId == venta.id).length;
    movimientos.add(
      MovimientoCaja(
        fecha: venta.fecha,
        tipo: TipoMovimientoCaja.venta,
        detalle: lineasVenta == 1
            ? 'Ticket · 1 producto'
            : 'Ticket · $lineasVenta productos',
        montos: montos,
      ),
    );
  }
  for (final linea in lineas) {
    // A cancelled line or a customer return hands its amount back.
    final devuelta =
        (linea.tipo == TipoMovimiento.venta && linea.anulada) ||
        linea.tipo == TipoMovimiento.devolucionCliente;
    final importe = linea.importe;
    if (!devuelta || importe == null || !caja.incluye(linea.fecha)) continue;
    final montos = <MedioPago, int>{};
    final medio = linea.medioReembolso;
    final reembolso = medio == null
        ? null
        : enMoneda(importe, medio.moneda, linea.tasa);
    if (medio != null && reembolso != null) {
      montos[medio] = -reembolso;
    } else {
      // Older returns didn't record how: taken as dollar cash.
      _restarEfectivo(
        montos,
        importe,
        linea.tipo == TipoMovimiento.venta ? porVenta[linea.ventaId] : null,
      );
    }
    movimientos.add(
      MovimientoCaja(
        fecha: linea.fecha,
        tipo: TipoMovimientoCaja.devolucion,
        detalle: linea.tipo == TipoMovimiento.venta
            ? 'Venta anulada · ${linea.producto}'
            : 'Devolución · ${linea.producto}',
        montos: montos,
      ),
    );
  }
  for (final compra in compras) {
    final medio = compra.medio;
    if (medio == null || !caja.incluye(compra.fecha)) continue;
    final monto = enMoneda(compra.total, medio.moneda, compra.tasa);
    if (monto == null) continue;
    movimientos.add(
      MovimientoCaja(
        fecha: compra.fecha,
        tipo: TipoMovimientoCaja.proveedor,
        detalle: _detalleCompra(compra, 'de contado'),
        montos: {medio: -monto},
      ),
    );
  }
  final porCompra = {for (final c in compras) c.id: c};
  for (final pago in pagos) {
    if (!caja.incluye(pago.fecha)) continue;
    final compra = porCompra[pago.compraId];
    movimientos.add(
      MovimientoCaja(
        fecha: pago.fecha,
        tipo: TipoMovimientoCaja.proveedor,
        detalle: compra == null
            ? 'Pago a proveedor'
            : _detalleCompra(compra, 'abono'),
        montos: {pago.medio: -pago.entregado},
      ),
    );
  }
  for (final gasto in gastos) {
    if (!caja.incluye(gasto.fecha)) continue;
    movimientos.add(
      MovimientoCaja(
        fecha: gasto.fecha,
        tipo: gasto.esIngreso
            ? TipoMovimientoCaja.ingreso
            : TipoMovimientoCaja.gasto,
        detalle: [
          gasto.categoria.etiqueta,
          if (gasto.nota.isNotEmpty) gasto.nota,
        ].join(' · '),
        montos: {gasto.medio: gasto.esIngreso ? gasto.monto : -gasto.monto},
      ),
    );
  }
  for (final d in devolucionesProveedor) {
    final medio = d.medio;
    final entregado = d.entregado;
    if (medio == null || entregado == null || !caja.incluye(d.fecha)) {
      continue;
    }
    movimientos.add(
      MovimientoCaja(
        fecha: d.fecha,
        tipo: TipoMovimientoCaja.proveedor,
        detalle: '${d.proveedor} · devolvió dinero por mercancía',
        montos: {medio: entregado},
      ),
    );
  }
  return movimientos..sort((a, b) => b.fecha.compareTo(a.fecha));
}

/// What there should be of each way of paying: the opening cash plus every
/// movement. Medios that never moved are left out.
Map<MedioPago, int> saldosDeCaja(List<MovimientoCaja> movimientos) {
  final saldos = <MedioPago, int>{};
  for (final m in movimientos) {
    for (final MapEntry(key: medio, value: monto) in m.montos.entries) {
      saldos[medio] = (saldos[medio] ?? 0) + monto;
    }
  }
  return {
    for (final medio in MedioPago.values)
      if (saldos.containsKey(medio)) medio: saldos[medio]!,
  };
}

/// The balances in dollar hundredths at [tasa]; bolívares without a rate
/// count nothing.
int totalEnDolares(Map<MedioPago, int> saldos, int? tasa) => saldos.entries
    .fold(0, (suma, e) => suma + (aDolares(e.value, e.key.moneda, tasa) ?? 0));

void _restarEfectivo(Map<MedioPago, int> montos, int dolares, Venta? venta) {
  final enDolares =
      venta == null ||
      venta.tasa == null ||
      venta.pagos.any((p) => p.medio == MedioPago.efectivoDolares);
  if (enDolares) {
    montos[MedioPago.efectivoDolares] =
        (montos[MedioPago.efectivoDolares] ?? 0) - dolares;
  } else {
    montos[MedioPago.efectivoBolivares] =
        (montos[MedioPago.efectivoBolivares] ?? 0) -
        dividirRedondeando(dolares * venta.tasa!, 100);
  }
}

String _detalleCompra(Compra compra, String como) => [
  compra.proveedor,
  if (compra.factura.isNotEmpty) 'factura ${compra.factura}',
  como,
].join(' · ');
