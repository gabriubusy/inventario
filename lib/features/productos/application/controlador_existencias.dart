import 'package:flutter/foundation.dart';
import 'package:inventario/features/productos/application/estado_existencias.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/filtro_productos.dart';
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
    _estado = ExistenciasCargadas(productos);
    notifyListeners();
  }

  /// Adds the product to the list as soon as the repository accepts it.
  Future<ResultadoGuardarProducto> crearProducto(DatosProducto datos) async {
    final resultado = await _repositorio.crear(datos);
    if (resultado case ProductoGuardado(:final producto)) {
      _estado = ExistenciasCargadas([...productos, producto]);
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
      _estado = ExistenciasCargadas([
        for (final p in productos) p.id == id ? producto : p,
      ]);
      notifyListeners();
    }
    return resultado;
  }

  Future<void> borrarProducto(String id) async {
    await _repositorio.borrar(id);
    _estado = ExistenciasCargadas([
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
