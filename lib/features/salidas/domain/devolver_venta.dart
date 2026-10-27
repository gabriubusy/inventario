import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// The product with a cancelled sale's goods back in its brand lot. A piece
/// the sale opened is closed again, as long as it is still the open one.
/// If the lot is gone, it comes back as a new lot of that brand.
Producto devolverVenta(
  Producto producto, {
  required String marca,
  required String proveedor,
  required int piezas,
  required int cantidad,
  required bool abrioPieza,
}) {
  final claveMarca = normalizarParaBusqueda(marca);
  final claveProveedor = normalizarParaBusqueda(proveedor);
  final indice = producto.lotes.indexWhere(
    (lote) =>
        normalizarParaBusqueda(lote.marca) == claveMarca &&
        normalizarParaBusqueda(lote.proveedor) == claveProveedor,
  );
  if (indice == -1) {
    return producto.copyWith(
      lotes: [
        ...producto.lotes,
        LoteMarca(
          marca: marca,
          proveedor: proveedor,
          piezas: piezas,
          cantidad: cantidad,
        ),
      ],
    );
  }
  final lote = producto.lotes[indice];
  final cierra = abrioPieza && lote.piezaAbierta;
  final devuelto = lote.copyWith(
    piezas: lote.piezas + piezas + (cierra ? 1 : 0),
    piezaAbierta: lote.piezaAbierta && !cierra,
    cantidad: lote.cantidad + cantidad,
  );
  return producto.copyWith(
    lotes: [
      for (final (i, l) in producto.lotes.indexed) i == indice ? devuelto : l,
    ],
  );
}
