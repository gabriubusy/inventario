import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// Position of the lot of that brand and supplier, ignoring case and
/// accents, or -1 when the product has none.
int indiceLote(Producto producto, String marca, String proveedor) {
  final claveMarca = normalizarParaBusqueda(marca);
  final claveProveedor = normalizarParaBusqueda(proveedor);
  return producto.lotes.indexWhere(
    (lote) =>
        normalizarParaBusqueda(lote.marca) == claveMarca &&
        normalizarParaBusqueda(lote.proveedor) == claveProveedor,
  );
}

/// Whether the lot holds at least that much to take out.
bool alcanza(LoteMarca lote, {required int piezas, required int cantidad}) =>
    piezas <= lote.piezas && cantidad <= lote.cantidad;

/// The product without the damaged goods; null when the lot is gone or
/// does not hold that much.
Producto? sacarDeLote(
  Producto producto, {
  required String marca,
  required String proveedor,
  required int piezas,
  required int cantidad,
}) {
  final indice = indiceLote(producto, marca, proveedor);
  if (indice == -1) return null;
  final lote = producto.lotes[indice];
  if (!alcanza(lote, piezas: piezas, cantidad: cantidad)) return null;
  final restante = lote.cantidad - cantidad;
  return producto.copyWith(
    lotes: [
      for (final (i, l) in producto.lotes.indexed)
        i == indice
            ? l.copyWith(
                piezas: l.piezas - piezas,
                // Nothing is left open once its weight is gone.
                piezaAbierta: l.piezaAbierta && restante > 0,
                cantidad: restante,
              )
            : l,
    ],
  );
}
