import 'package:inventario/core/texto.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/repositorio_movimientos.dart';

/// Stand-in until local persistence is decided; lost when the app closes.
class RepositorioMovimientosEnMemoria implements RepositorioMovimientos {
  RepositorioMovimientosEnMemoria([List<Movimiento> iniciales = const []])
    : _movimientos = [...iniciales];

  final List<Movimiento> _movimientos;
  var _ultimoId = 0;

  @override
  Future<List<Movimiento>> obtenerTodos() async =>
      List.unmodifiable(_movimientos);

  @override
  Future<Movimiento> anotar(Movimiento movimiento) async {
    final guardado = movimiento.conId(_nuevoId());
    _movimientos.add(guardado);
    return guardado;
  }

  @override
  Future<void> quitar(String id) async =>
      _movimientos.removeWhere((m) => m.id == id);

  @override
  Future<void> anular(String id, {DateTime? el}) async {
    final indice = _movimientos.indexWhere((m) => m.id == id);
    if (indice >= 0) _movimientos[indice] = _movimientos[indice].anulado(el);
  }

  @override
  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    final clave = normalizarParaBusqueda(anterior);
    for (final (i, m) in _movimientos.indexed) {
      if (normalizarParaBusqueda(m.proveedor) == clave) {
        _movimientos[i] = m.conProveedor(nuevo);
      }
    }
  }

  // Skips ids already taken by the initial movements.
  String _nuevoId() {
    String id;
    do {
      id = 'm${++_ultimoId}';
    } while (_movimientos.any((m) => m.id == id));
    return id;
  }
}
