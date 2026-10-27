import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// Sold-out products first, then those under their minimum; each keeps
/// its relative order.
List<Producto> porReponer(List<Producto> productos) => [
  for (final estado in [EstadoStock.agotado, EstadoStock.bajo])
    for (final producto in productos)
      if (producto.estado == estado) producto,
];

/// Suppliers that bring the product, without repeats: who to ask.
List<String> proveedoresDe(Producto producto) {
  final vistos = <String>{};
  return [
    for (final lote in producto.lotes)
      if (lote.proveedor.isNotEmpty &&
          vistos.add(normalizarParaBusqueda(lote.proveedor)))
        lote.proveedor,
  ];
}
