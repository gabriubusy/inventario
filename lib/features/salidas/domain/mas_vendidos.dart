import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';

/// Ids of the products sold most often in the last [dias] days, best first:
/// the quick buttons of the sale window. Ties go to the latest sold.
List<String> masVendidos(
  List<Movimiento> movimientos,
  DateTime hoy, {
  int dias = 30,
  int cuantos = 8,
}) {
  final veces = <String, int>{};
  final ultima = <String, DateTime>{};
  for (final m in movimientos) {
    if (m.tipo != TipoMovimiento.venta || m.anulada) continue;
    final hace = diasEntre(m.fecha, hoy);
    if (hace < 0 || hace >= dias) continue;
    veces[m.productoId] = (veces[m.productoId] ?? 0) + 1;
    final previa = ultima[m.productoId];
    if (previa == null || m.fecha.isAfter(previa)) {
      ultima[m.productoId] = m.fecha;
    }
  }
  final ids = veces.keys.toList()
    ..sort((a, b) {
      final porVeces = veces[b]!.compareTo(veces[a]!);
      return porVeces != 0 ? porVeces : ultima[b]!.compareTo(ultima[a]!);
    });
  return ids.take(cuantos).toList();
}
