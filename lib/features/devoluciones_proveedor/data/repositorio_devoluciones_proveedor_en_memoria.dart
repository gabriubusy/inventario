import 'package:inventario/core/texto.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/devolucion_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/repositorio_devoluciones_proveedor.dart';

/// For tests; lost when the app closes.
class RepositorioDevolucionesProveedorEnMemoria
    implements RepositorioDevolucionesProveedor {
  RepositorioDevolucionesProveedorEnMemoria([
    List<DevolucionProveedor> iniciales = const [],
  ]) : _todas = [...iniciales];

  final List<DevolucionProveedor> _todas;
  var _ultimoId = 0;

  @override
  Future<List<DevolucionProveedor>> obtenerTodas() async =>
      List.unmodifiable(_todas);

  @override
  Future<DevolucionProveedor> crear(DevolucionProveedor devolucion) async {
    final guardada = devolucion.conId('d${++_ultimoId}');
    _todas.add(guardada);
    return guardada;
  }

  @override
  Future<void> borrar(String id) async => _todas.removeWhere((d) => d.id == id);

  @override
  Future<void> actualizar(DevolucionProveedor devolucion) async {
    final i = _todas.indexWhere((d) => d.id == devolucion.id);
    if (i != -1) _todas[i] = devolucion;
  }

  @override
  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    final clave = normalizarParaBusqueda(anterior);
    for (final (i, d) in _todas.indexed) {
      if (normalizarParaBusqueda(d.proveedor) == clave) {
        _todas[i] = d.conProveedor(nuevo);
      }
    }
  }
}
