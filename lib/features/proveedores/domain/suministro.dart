import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';

/// One product lot that a supplier brought.
typedef Suministro = ({Producto producto, LoteMarca lote});

/// What [proveedor] brings, found through the brand lots of each product.
List<Suministro> suministrosDe(Proveedor proveedor, List<Producto> productos) {
  final clave = normalizarParaBusqueda(proveedor.nombre);
  return [
    for (final producto in productos)
      for (final lote in producto.lotes)
        if (normalizarParaBusqueda(lote.proveedor) == clave)
          (producto: producto, lote: lote),
  ];
}

/// Brand names in the order they first appear, without repeats.
List<String> marcasDe(List<Suministro> suministros) {
  final vistas = <String>{};
  return [
    for (final s in suministros)
      if (vistas.add(normalizarParaBusqueda(s.lote.marca))) s.lote.marca,
  ];
}

/// Matches by supplier name or by any brand it brings.
bool coincideProveedor(
  Proveedor proveedor,
  List<Suministro> suministros,
  String texto,
) {
  final buscado = normalizarParaBusqueda(texto);
  if (buscado.isEmpty) return true;
  if (normalizarParaBusqueda(proveedor.nombre).contains(buscado)) return true;
  return suministros.any(
    (s) => normalizarParaBusqueda(s.lote.marca).contains(buscado),
  );
}
