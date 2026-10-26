import 'package:flutter/foundation.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/filtro_estado.dart';
import 'package:inventario/features/productos/domain/filtro_productos.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// Search, quick filter and selection of the products screen. The products
/// come from the stock, so screens should also listen to [existencias].
class ControladorListaProductos extends ChangeNotifier {
  ControladorListaProductos(this.existencias);

  final ControladorExistencias existencias;
  String _busqueda = '';
  FiltroEstado _filtro = FiltroEstado.todos;
  String? _elegidoId;

  String get busqueda => _busqueda;
  FiltroEstado get filtro => _filtro;

  List<Producto> get visibles => filtrarProductos(
    existencias.productos,
    texto: _busqueda,
    filtro: _filtro,
  );

  /// The chosen product, or the first visible one.
  Producto? get elegido {
    final lista = visibles;
    if (lista.isEmpty) return null;
    return lista.firstWhere(
      (p) => p.id == _elegidoId,
      orElse: () => lista.first,
    );
  }

  void buscar(String texto) {
    if (texto == _busqueda) return;
    _busqueda = texto;
    notifyListeners();
  }

  void filtrar(FiltroEstado filtro) {
    if (filtro == _filtro) return;
    _filtro = filtro;
    notifyListeners();
  }

  void elegir(String id) {
    if (id == _elegidoId) return;
    _elegidoId = id;
    notifyListeners();
  }

  /// Moves the selection up (negative) or down, stopping at the ends.
  void moverEleccion(int pasos) {
    final lista = visibles;
    final actual = elegido;
    if (actual == null) return;
    final destino = (lista.indexOf(actual) + pasos).clamp(0, lista.length - 1);
    elegir(lista[destino].id);
  }
}
