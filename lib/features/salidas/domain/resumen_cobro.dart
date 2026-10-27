import 'dart:math' as math;

import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';

/// How the payments stand against the total, everything in dollar
/// hundredths with Bs converted at [tasa] (Bs per dollar, hundredths).
class ResumenCobro {
  ResumenCobro({required this.total, required this.pagos, required this.tasa})
    : pagado = pagos.fold(0, (suma, p) => suma + p.enDolares(tasa));

  final int total;
  final List<PagoVenta> pagos;
  final int tasa;
  final int pagado;

  int get falta => math.max(0, total - pagado);

  int get vuelto => math.max(0, pagado - total);

  int get vueltoEnBolivares => dividirRedondeando(vuelto * tasa, 100);

  /// Change is only handed back in cash: paying too much by transfer or
  /// card is a typo, not change.
  bool get vueltoSinEfectivo =>
      vuelto > 0 && !pagos.any((p) => p.medio.esEfectivo);

  bool get puedeRegistrarse => falta == 0 && !vueltoSinEfectivo;
}
