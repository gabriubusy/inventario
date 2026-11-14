import 'package:flutter/foundation.dart';
import 'package:inventario/features/productos/application/estado_existencias.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/filtro_productos.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/por_reponer.dart'
    as dominio;
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/repositorio_productos.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';

class ControladorExistencias extends ChangeNotifier {
  ControladorExistencias(this._repositorio);

  final RepositorioProductos _repositorio;
  EstadoExistencias _estado = const CargandoExistencias();
  String _busqueda = '';
  Categoria? _categoria;

  EstadoExistencias get estado => _estado;
  String get busqueda => _busqueda;

  /// Null means every category.
  Categoria? get categoria => _categoria;

  /// Every product, ignoring the search and category filters.
  List<Producto> get productos => switch (_estado) {
    CargandoExistencias() => const [],
    ExistenciasCargadas(:final productos) => productos,
  };

  List<Producto>? _porReponer;

  /// Sold out and below the minimum, for the home banner and the day
  /// panel: both ask on every repaint, so it is worked out once per change.
  List<Producto> get porReponer =>
      _porReponer ??= dominio.porReponer(productos);

  List<Producto> get visibles => switch (_estado) {
    CargandoExistencias() => const [],
    ExistenciasCargadas(:final productos) => filtrarProductos(
      productos,
      texto: _busqueda,
      categoria: _categoria,
    ),
  };

  Future<void> cargar() async {
    final productos = await _repositorio.obtenerTodos();
    _ponerProductos(productos);
    notifyListeners();
  }

  void _ponerProductos(List<Producto> productos) {
    _estado = ExistenciasCargadas(productos);
    _porReponer = null;
  }

  /// Adds the product to the list as soon as the repository accepts it.
  /// The last new product's category and way of counting: the next one is
  /// usually alike, so the form starts with them.
  ({Categoria categoria, FormaConteo forma})? ultimoCreado;

  Future<ResultadoGuardarProducto> crearProducto(DatosProducto datos) async {
    final resultado = await _repositorio.crear(datos);
    if (resultado case ProductoGuardado(:final producto)) {
      ultimoCreado = (categoria: producto.categoria, forma: producto.forma);
      _ponerProductos([...productos, producto]);
      notifyListeners();
    }
    return resultado;
  }

  /// Replaces the product in place, so it keeps its spot in the lists.
  Future<ResultadoGuardarProducto> actualizarProducto(
    String id,
    DatosProducto datos,
  ) async {
    final resultado = await _repositorio.actualizar(id, datos);
    if (resultado case ProductoGuardado(:final producto)) {
      _ponerProductos([for (final p in productos) p.id == id ? producto : p]);
      notifyListeners();
    }
    return resultado;
  }

  Future<void> borrarProducto(String id) async {
    await _repositorio.borrar(id);
    _ponerProductos([
      for (final p in productos)
        if (p.id != id) p,
    ]);
    notifyListeners();
  }

  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    await _repositorio.renombrarProveedor(anterior, nuevo);
    await cargar();
  }

  void buscar(String texto) {
    if (texto == _busqueda) return;
    _busqueda = texto;
    notifyListeners();
  }

  void elegirCategoria(Categoria? categoria) {
    if (categoria == _categoria) return;
    _categoria = categoria;
    notifyListeners();
  }
}
