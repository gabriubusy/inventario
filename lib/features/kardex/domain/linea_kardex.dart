import 'package:inventario/features/movimientos/domain/movimiento.dart';

/// One kardex row: what came in or went out, and the stock right after.
/// Amounts are scaled like [Movimiento.cantidad]; one of the two is 0.
typedef LineaKardex = ({Movimiento movimiento, int entra, int sale, int saldo});

/// Rows newest first. The balance runs backwards from [stockActual], so it
/// is right even when older movements were never recorded. Cancelled sales
/// gave their goods back and are left out.
List<LineaKardex> lineasKardex(List<Movimiento> movimientos, int stockActual) {
  final validos = [
    for (final m in movimientos)
      if (!m.anulada) m,
  ]..sort((a, b) => b.fecha.compareTo(a.fecha));
  var saldo = stockActual;
  final lineas = <LineaKardex>[];
  for (final m in validos) {
    final entra = m.tipo.signo > 0 ? m.cantidad : 0;
    final sale = m.tipo.signo < 0 ? m.cantidad : 0;
    lineas.add((movimiento: m, entra: entra, sale: sale, saldo: saldo));
    saldo -= entra - sale;
  }
  return lineas;
}
