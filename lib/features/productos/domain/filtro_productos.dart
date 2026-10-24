import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// Keeps the products that match, most urgent first and then by name.
List<Producto> filtrarProductos(
  List<Producto> productos, {
  String texto = '',
  Categoria? categoria,
}) {
  final buscado = normalizarParaBusqueda(texto);
  final resultado = [
    for (final producto in productos)
      if ((categoria == null || producto.categoria == categoria) &&
          normalizarParaBusqueda(producto.nombre).contains(buscado))
        producto,
  ];
  resultado.sort((a, b) {
    final porEstado = a.estado.index.compareTo(b.estado.index);
    return porEstado != 0 ? porEstado : a.nombre.compareTo(b.nombre);
  });
  return resultado;
}
