import 'package:inventario/core/texto.dart';
import 'package:inventario/features/incidencias/domain/datos_incidencia.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/repositorio_incidencias.dart';

/// Stand-in until local persistence is decided; lost when the app closes.
class RepositorioIncidenciasEnMemoria implements RepositorioIncidencias {
  RepositorioIncidenciasEnMemoria([List<Incidencia> iniciales = const []])
    : _incidencias = [...iniciales];

  final List<Incidencia> _incidencias;
  var _ultimoId = 0;

  @override
  Future<List<Incidencia>> obtenerTodas() async =>
      List.unmodifiable(_incidencias);

  @override
  Future<Incidencia> crear(DatosIncidencia datos) async {
    final incidencia = Incidencia.desde(_nuevoId(), datos);
    _incidencias.add(incidencia);
    return incidencia;
  }

  @override
  Future<void> actualizar(Incidencia incidencia) async {
    final i = _incidencias.indexWhere((x) => x.id == incidencia.id);
    if (i != -1) _incidencias[i] = incidencia;
  }

  @override
  Future<void> borrar(String id) async =>
      _incidencias.removeWhere((x) => x.id == id);

  @override
  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    final clave = normalizarParaBusqueda(anterior);
    for (final (i, incidencia) in _incidencias.indexed) {
      if (normalizarParaBusqueda(incidencia.proveedor) == clave) {
        _incidencias[i] = incidencia.conProveedor(nuevo);
      }
    }
  }

  // Skips ids already taken by the initial incidents.
  String _nuevoId() {
    String id;
    do {
      id = 'i${++_ultimoId}';
    } while (_incidencias.any((x) => x.id == id));
    return id;
  }
}
