import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';

typedef PorCodigo = ({Producto producto, Presentacion presentacion});

/// The product and pack whose code is exactly [codigo], ignoring case and
/// spaces, as a barcode scanner types it; null when none has it.
PorCodigo? buscarPorCodigo(List<Producto> productos, String codigo) {
  final buscado = _clave(codigo);
  if (buscado.isEmpty) return null;
  for (final producto in productos) {
    for (final presentacion in producto.presentaciones) {
      if (_clave(presentacion.codigo) == buscado) {
        return (producto: producto, presentacion: presentacion);
      }
    }
  }
  return null;
}

/// Whether another product already uses [codigo]; codes must be unique so a
/// scan always lands on one pack.
bool codigoEnUso(
  List<Producto> productos,
  String codigo, {
  String? exceptoProductoId,
}) {
  final encontrado = buscarPorCodigo(productos, codigo);
  return encontrado != null && encontrado.producto.id != exceptoProductoId;
}

String _clave(String codigo) =>
    normalizarParaBusqueda(codigo).replaceAll(' ', '');
