import 'package:inventario/features/autenticacion/domain/usuario.dart';

/// Keeps the open session across reloads and restarts.
abstract interface class AlmacenSesion {
  Future<Usuario?> leer();
  Future<void> guardar(Usuario usuario);
  Future<void> borrar();
}
