import 'package:inventario/core/texto.dart';
import 'package:inventario/features/proveedores/domain/datos_proveedor.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/domain/repositorio_proveedores.dart';
import 'package:inventario/features/proveedores/domain/resultado_guardar_proveedor.dart';

/// Stand-in until local persistence is decided; lost when the app closes.
class RepositorioProveedoresEnMemoria implements RepositorioProveedores {
  RepositorioProveedoresEnMemoria(List<Proveedor> iniciales)
    : _proveedores = [...iniciales];

  final List<Proveedor> _proveedores;
  var _ultimoId = 0;

  @override
  Future<List<Proveedor>> obtenerTodos() async =>
      List.unmodifiable(_proveedores);

  @override
  Future<ResultadoGuardarProveedor> crear(DatosProveedor datos) async {
    if (_nombreUsado(datos.nombre)) return const NombreProveedorRepetido();
    final proveedor = _desde(_nuevoId(), datos);
    _proveedores.add(proveedor);
    return ProveedorGuardado(proveedor);
  }

  @override
  Future<ResultadoGuardarProveedor> actualizar(
    String id,
    DatosProveedor datos,
  ) async {
    if (_nombreUsado(datos.nombre, salvo: id)) {
      return const NombreProveedorRepetido();
    }
    final proveedor = _desde(id, datos);
    final i = _proveedores.indexWhere((p) => p.id == id);
    _proveedores[i] = proveedor;
    return ProveedorGuardado(proveedor);
  }

  bool _nombreUsado(String nombre, {String? salvo}) {
    final clave = normalizarParaBusqueda(nombre);
    return _proveedores.any(
      (p) => p.id != salvo && normalizarParaBusqueda(p.nombre) == clave,
    );
  }

  Proveedor _desde(String id, DatosProveedor datos) => Proveedor(
    id: id,
    nombre: datos.nombre,
    rif: datos.rif,
    telefono: datos.telefono,
    contacto: datos.contacto,
    notas: datos.notas,
  );

  // Skips ids already taken by the initial suppliers.
  String _nuevoId() {
    String id;
    do {
      id = 'v${++_ultimoId}';
    } while (_proveedores.any((p) => p.id == id));
    return id;
  }
}
