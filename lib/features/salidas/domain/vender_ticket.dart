import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/domain/linea_ticket.dart';
import 'package:inventario/features/salidas/domain/ticket.dart';
import 'package:inventario/features/salidas/domain/vender.dart';

typedef CambioProducto = ({Producto antes, Producto despues});

/// Each product of the ticket as it is now and after selling all its lines,
/// in the order they first appear. The first line the stock no longer
/// covers (or whose product is gone) comes back in `sinExistencias`.
({List<CambioProducto> cambios, LineaTicket? sinExistencias}) venderTicket(
  Ticket ticket,
  Producto? Function(String id) buscar,
) {
  final despues = <String, Producto>{};
  final antes = <String, Producto>{};
  for (final linea in ticket.lineas) {
    final actual = despues[linea.productoId] ?? buscar(linea.productoId);
    final vendido = actual == null ? null : vender(actual, linea.salida);
    if (actual == null || vendido == null) {
      return (cambios: const [], sinExistencias: linea);
    }
    antes.putIfAbsent(linea.productoId, () => actual);
    despues[linea.productoId] = vendido;
  }
  return (
    cambios: [
      for (final MapEntry(key: id, value: original) in antes.entries)
        (antes: original, despues: despues[id]!),
    ],
    sinExistencias: null,
  );
}
