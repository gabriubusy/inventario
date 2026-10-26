import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/filtro_estado.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// Keeps the products that match, most urgent first and then by name.
/// The text is looked for in the name and in the brands.
List<Producto> filtrarProductos(
  List<Producto> productos, {
  String texto = '',
  Categoria? categoria,
  FiltroEstado filtro = FiltroEstado.todos,
}) {
  final buscado = normalizarParaBusqueda(texto);
  final resultado = [
    for (final producto in productos)
      if ((categoria == null || producto.categoria == categoria) &&
          filtro.admite(producto.estado) &&
          _coincide(producto, buscado))
        producto,
  ];
  resultado.sort((a, b) {
    final porEstado = a.estado.index.compareTo(b.estado.index);
    return porEstado != 0 ? porEstado : a.nombre.compareTo(b.nombre);
  });
  return resultado;
}

bool _coincide(Producto producto, String buscado) =>
    normalizarParaBusqueda(producto.nombre).contains(buscado) ||
    producto.lotes.any(
      (lote) => normalizarParaBusqueda(lote.marca).contains(buscado),
    );
