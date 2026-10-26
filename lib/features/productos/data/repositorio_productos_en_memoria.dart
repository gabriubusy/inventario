import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/repositorio_productos.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';

/// Stand-in until local persistence is decided; lost when the app closes.
class RepositorioProductosEnMemoria implements RepositorioProductos {
  RepositorioProductosEnMemoria(List<Producto> iniciales)
    : _productos = [...iniciales];

  final List<Producto> _productos;
  var _ultimoId = 0;

  @override
  Future<List<Producto>> obtenerTodos() async => List.unmodifiable(_productos);

  @override
  Future<ResultadoGuardarProducto> crear(DatosProducto datos) async {
    if (_nombreUsado(datos.nombre)) return const NombreRepetido();
    final producto = _construir(_nuevoId(), datos);
    _productos.add(producto);
    return ProductoGuardado(producto);
  }

  @override
  Future<ResultadoGuardarProducto> actualizar(
    String id,
    DatosProducto datos,
  ) async {
    final indice = _productos.indexWhere((p) => p.id == id);
    if (indice < 0) throw StateError('No product with id $id');
    if (_nombreUsado(datos.nombre, excepto: id)) return const NombreRepetido();
    final producto = _construir(id, datos);
    _productos[indice] = producto;
    return ProductoGuardado(producto);
  }

  bool _nombreUsado(String nombre, {String? excepto}) {
    final clave = normalizarParaBusqueda(nombre);
    return _productos.any(
      (p) => p.id != excepto && normalizarParaBusqueda(p.nombre) == clave,
    );
  }

  Producto _construir(String id, DatosProducto datos) => Producto(
    id: id,
    nombre: datos.nombre,
    categoria: datos.categoria,
    forma: datos.forma,
    minimo: datos.minimo,
    lotes: List.unmodifiable(datos.lotes),
    imagenId: datos.imagenId,
  );

  @override
  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    final clave = normalizarParaBusqueda(anterior);
    for (final (i, producto) in _productos.indexed) {
      if (!producto.lotes.any(
        (l) => normalizarParaBusqueda(l.proveedor) == clave,
      )) {
        continue;
      }
      _productos[i] = producto.copyWith(
        lotes: List.unmodifiable([
          for (final lote in producto.lotes)
            normalizarParaBusqueda(lote.proveedor) == clave
                ? lote.copyWith(proveedor: nuevo)
                : lote,
        ]),
      );
    }
  }

  // Skips ids already taken by the initial products.
  String _nuevoId() {
    String id;
    do {
      id = 'p${++_ultimoId}';
    } while (_productos.any((p) => p.id == id));
    return id;
  }
}
