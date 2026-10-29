import 'package:inventario/core/fechas.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/pago.dart';

/// Where an invoice on credit stands.
enum EstadoCuenta {
  pagada('Pagada'),
  vencida('Vencida'),
  porVencer('Vence pronto'),
  alDia('Al día');

  const EstadoCuenta(this.etiqueta);

  final String etiqueta;
}

/// An invoice on credit with what was paid so far.
class CuentaPorPagar {
  const CuentaPorPagar({
    required this.compra,
    required this.pagos,
    this.devuelto = 0,
  });

  /// Days ahead in which an invoice counts as "vence pronto".
  static const diasAviso = 7;

  final Compra compra;
  final List<Pago> pagos;

  /// Goods sent back that the supplier took off this invoice, in dollar
  /// hundredths.
  final int devuelto;

  /// In dollar hundredths.
  int get abonado => pagos.fold(0, (suma, p) => suma + p.monto);

  int get debe => compra.total - abonado - devuelto;

  /// Negative once it is overdue.
  int diasParaVencer(DateTime hoy) => diasEntre(hoy, compra.vence ?? hoy);

  EstadoCuenta estado(DateTime hoy) {
    if (debe <= 0) return EstadoCuenta.pagada;
    final dias = diasParaVencer(hoy);
    if (dias < 0) return EstadoCuenta.vencida;
    if (dias <= diasAviso) return EstadoCuenta.porVencer;
    return EstadoCuenta.alDia;
  }
}

/// Dollar hundredths for [entregado] in [moneda]; null for bolívares
/// without a rate.
int? aDolares(int entregado, Moneda moneda, int? tasa) => switch (moneda) {
  Moneda.dolares => entregado,
  Moneda.bolivares =>
    tasa == null || tasa <= 0
        ? null
        : dividirRedondeando(entregado * 100, tasa),
};

/// Hundredths of [moneda] that pay [dolares]; null for bolívares without a
/// rate.
int? enMoneda(int dolares, Moneda moneda, int? tasa) => switch (moneda) {
  Moneda.dolares => dolares,
  Moneda.bolivares =>
    tasa == null ? null : dividirRedondeando(dolares * tasa, 100),
};
