import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// One product before and after losing a brand's lot.
typedef CambioMarca = ({Producto antes, Producto despues});

/// Nothing is left of [marca] from [proveedor]. Only then does it make sense
/// to take the brand off the supplier: stock moves with sales, losses or
/// Conteo (F9), never by editing the supplier.
bool marcaSinExistencias(
  List<Producto> productos, {
  required String proveedor,
  required String marca,
}) {
  final esLote = _lotesDe(proveedor, marca);
  return !productos.any(
    (p) => p.lotes.any((l) => esLote(l) && l.tieneExistencia),
  );
}

/// Every product of [proveedor] that carries [marca], as it is left without
/// that lot; empty when no product has it.
List<CambioMarca> productosSinMarca(
  List<Producto> productos, {
  required String proveedor,
  required String marca,
}) {
  final esLote = _lotesDe(proveedor, marca);
  return [
    for (final producto in productos)
      if (producto.lotes.any(esLote))
        (
          antes: producto,
          despues: producto.copyWith(
            lotes: [
              for (final lote in producto.lotes)
                if (!esLote(lote)) lote,
            ],
          ),
        ),
  ];
}

/// Brand and supplier identify a lot, both ignoring case and accents.
bool Function(LoteMarca) _lotesDe(String proveedor, String marca) {
  final deQuien = normalizarParaBusqueda(proveedor);
  final cual = normalizarParaBusqueda(marca);
  return (lote) =>
      normalizarParaBusqueda(lote.proveedor) == deQuien &&
      normalizarParaBusqueda(lote.marca) == cual;
}
