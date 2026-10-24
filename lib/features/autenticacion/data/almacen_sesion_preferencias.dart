import 'package:inventario/features/autenticacion/domain/almacen_sesion.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlmacenSesionPreferencias implements AlmacenSesion {
  AlmacenSesionPreferencias([SharedPreferencesAsync? preferencias])
    : _preferencias = preferencias ?? SharedPreferencesAsync();

  static const _claveId = 'sesion.usuario.id';
  static const _claveNombre = 'sesion.usuario.nombre';

  final SharedPreferencesAsync _preferencias;

  @override
  Future<Usuario?> leer() async {
    final id = await _preferencias.getString(_claveId);
    final nombre = await _preferencias.getString(_claveNombre);
    if (id == null || nombre == null) return null;
    return Usuario(id: id, nombre: nombre);
  }

  @override
  Future<void> guardar(Usuario usuario) async {
    await _preferencias.setString(_claveId, usuario.id);
    await _preferencias.setString(_claveNombre, usuario.nombre);
  }

  @override
  Future<void> borrar() =>
      _preferencias.clear(allowList: {_claveId, _claveNombre});
}
