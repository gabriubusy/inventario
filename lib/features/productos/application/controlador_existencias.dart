import 'package:flutter/foundation.dart';
import 'package:inventario/features/productos/application/estado_existencias.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/filtro_productos.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/repositorio_productos.dart';

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
