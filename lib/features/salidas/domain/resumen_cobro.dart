import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';

/// How the payments stand against the total, in dollar hundredths with Bs
/// converted at [tasa] (Bs per dollar, hundredths).
class ResumenCobro {
  ResumenCobro({required this.total, required this.pagos, required this.tasa})
    : pagado = pagos.fold(0, (suma, p) => suma + p.enDolares(tasa)),
      _exceso = _excesoExacto(total, pagos, tasa);

  final int total;
  final List<PagoVenta> pagos;
  final int tasa;

  /// Rounded per payment; for showing only.
  final int pagado;

  /// Paid minus total, in dollar hundredths × [tasa] (= Bs hundredths
  /// × 100), so no payment in Bs is rounded to dollar cents first.
  final int _exceso;

  static int _excesoExacto(int total, List<PagoVenta> pagos, int tasa) {
    // Without a rate one unit is one cent and bolívares can't be valued.
    final escala = tasa == 0 ? 1 : tasa;
    final pagadoExacto = pagos.fold(
      0,
      (suma, p) =>
          suma +
          switch (p.medio.moneda) {
            Moneda.dolares => p.monto * escala,
            Moneda.bolivares => tasa == 0 ? 0 : p.monto * 100,
          },
    );
    return pagadoExacto - total * escala;
  }

  int get _escala => tasa == 0 ? 1 : tasa;

  /// Half a Bs cent: an exact amount in Bs is rounded to the cent and may
  /// fall short by that much, never more.
  int get _tolerancia => tasa == 0 ? 0 : 50;

  /// Any real shortfall, even under a dollar cent, still counts as missing.
  int get falta =>
      _exceso >= -_tolerancia ? 0 : (-_exceso + _escala - 1) ~/ _escala;

  /// What is missing in Bs hundredths, from the exact shortfall: paying it
  /// in Bs leaves neither a gap nor a phantom cent of change.
  int get faltaEnBolivares => _exceso >= -_tolerancia || tasa == 0
      ? 0
      : dividirRedondeando(-_exceso, 100);

  int get vuelto => _exceso <= 0 ? 0 : dividirRedondeando(_exceso, _escala);

  /// The change straight from the exact excess, not from dollar cents.
  int get vueltoEnBolivares =>
      _exceso <= 0 || tasa == 0 ? 0 : dividirRedondeando(_exceso, 100);

  /// Change is only handed back in cash: paying too much by transfer or
  /// card is a typo, not change.
  bool get vueltoSinEfectivo =>
      vuelto > 0 && !pagos.any((p) => p.medio.esEfectivo);

  bool get puedeRegistrarse => falta == 0 && !vueltoSinEfectivo;
}
