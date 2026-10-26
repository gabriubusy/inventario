import 'package:inventario/core/texto.dart';
import 'package:inventario/features/entradas/domain/entrada.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// Position of the lot the entry goes to (same brand and supplier,
/// ignoring case and accents), or -1 when it is a new brand lot.
int indiceLoteDeEntrada(Producto producto, Entrada entrada) {
  final marca = normalizarParaBusqueda(entrada.marca);
  final proveedor = normalizarParaBusqueda(entrada.proveedor);
  return producto.lotes.indexWhere(
    (lote) =>
        normalizarParaBusqueda(lote.marca) == marca &&
        normalizarParaBusqueda(lote.proveedor) == proveedor,
  );
}

/// The product with the entry added to its lot, or to a new lot at the end.
Producto sumarEntrada(Producto producto, Entrada entrada) {
  final indice = indiceLoteDeEntrada(producto, entrada);
  if (indice == -1) {
    return producto.copyWith(
      lotes: [
        ...producto.lotes,
        LoteMarca(
          marca: entrada.marca,
          proveedor: entrada.proveedor,
          piezas: entrada.piezas,
          cantidad: entrada.cantidad,
        ),
      ],
    );
  }
  return producto.copyWith(
    lotes: [
      for (final (i, lote) in producto.lotes.indexed)
        i == indice
            ? lote.copyWith(
                piezas: lote.piezas + entrada.piezas,
                cantidad: lote.cantidad + entrada.cantidad,
              )
            : lote,
    ],
  );
}
