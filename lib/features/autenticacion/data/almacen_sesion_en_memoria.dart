import 'package:inventario/features/autenticacion/domain/almacen_sesion.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';

/// Forgets the session on reload; meant for tests.
class AlmacenSesionEnMemoria implements AlmacenSesion {
  AlmacenSesionEnMemoria([this._usuario]);

  Usuario? _usuario;

  @override
  Future<Usuario?> leer() async => _usuario;

  @override
  Future<void> guardar(Usuario usuario) async => _usuario = usuario;

  @override
  Future<void> borrar() async => _usuario = null;
}
