import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/medio_pago.dart';

/// "$ 12,40" or "12,40 Bs" in the currency of [moneda].
String textoEnMoneda(int centimos, Moneda moneda) => switch (moneda) {
  Moneda.dolares => formatearDolares(centimos),
  Moneda.bolivares => formatearBolivares(centimos),
};

/// Like [textoEnMoneda] with its sign: "+$ 6,50", "−1.800,00 Bs".
String textoConSigno(int centimos, Moneda moneda) {
  final signo = centimos < 0 ? '−' : '+';
  return '$signo${textoEnMoneda(centimos.abs(), moneda)}';
}
