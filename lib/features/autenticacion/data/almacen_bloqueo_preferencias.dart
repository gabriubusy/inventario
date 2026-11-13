import 'package:inventario/features/autenticacion/domain/almacen_bloqueo.dart';
import 'package:inventario/features/autenticacion/domain/minutos_bloqueo.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kept on this computer, like the rest of the PIN settings.
class AlmacenBloqueoPreferencias implements AlmacenBloqueo {
  AlmacenBloqueoPreferencias([SharedPreferencesAsync? preferencias])
    : _preferencias = preferencias ?? SharedPreferencesAsync();

  static const _clave = 'bloqueo.minutos';

  final SharedPreferencesAsync _preferencias;

  @override
  Future<int> leerMinutos() async =>
      await _preferencias.getInt(_clave) ?? MinutosBloqueo.porDefecto;

  @override
  Future<void> guardarMinutos(int minutos) =>
      _preferencias.setInt(_clave, minutos);
}
