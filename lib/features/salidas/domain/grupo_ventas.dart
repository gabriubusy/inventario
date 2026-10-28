import 'package:inventario/core/texto.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';

/// A paid ticket's lines together, or a lone one-product sale.
class GrupoVentas {
  const GrupoVentas({this.ventaId, required this.lineas});

  /// The ticket's id; null for a sale made one product at a time.
  final String? ventaId;

  /// In the order they were sold.
  final List<Movimiento> lineas;

  DateTime get fecha => lineas.first.fecha;

  /// What the lines still count for: cancelled ones add nothing.
  int get total => lineas
      .where((l) => !l.anulada)
      .fold(0, (suma, l) => suma + (l.importe ?? 0));
}

/// [ventas] (newest first) grouped by ticket, newest ticket first. With
/// [filtro], only tickets with a product whose name contains it.
List<GrupoVentas> agruparPorTicket(
  List<Movimiento> ventas, {
  String filtro = '',
}) {
  final porTicket = <String, List<Movimiento>>{};
  final grupos = <GrupoVentas>[];
  for (final venta in ventas) {
    final id = venta.ventaId;
    if (id == null) {
      grupos.add(GrupoVentas(lineas: [venta]));
    } else if (porTicket[id] case final lineas?) {
      lineas.add(venta);
    } else {
      final lineas = [venta];
      porTicket[id] = lineas;
      grupos.add(GrupoVentas(ventaId: id, lineas: lineas));
    }
  }
  final clave = normalizarParaBusqueda(filtro);
  return [
    for (final grupo in grupos)
      if (clave.isEmpty ||
          grupo.lineas.any(
            (l) => normalizarParaBusqueda(l.producto).contains(clave),
          ))
        GrupoVentas(
          ventaId: grupo.ventaId,
          lineas: grupo.lineas.reversed.toList(),
        ),
  ];
}
