import 'package:inventario/features/configuracion/domain/ajustes_respaldo.dart';
import 'package:inventario/features/configuracion/domain/almacen_ajustes_respaldo.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kept on this computer, not in the database: a backup restored on another
/// computer must not bring back a folder that doesn't exist there.
class AlmacenAjustesRespaldoPreferencias implements AlmacenAjustesRespaldo {
  AlmacenAjustesRespaldoPreferencias([SharedPreferencesAsync? preferencias])
    : _preferencias = preferencias ?? SharedPreferencesAsync();

  static const _claveCarpeta = 'respaldo.carpeta';
  static const _claveDias = 'respaldo.diasRecordatorio';
  static const _claveUltimo = 'respaldo.ultimo';
  static const _clavePospuesto = 'respaldo.pospuestoHasta';

  final SharedPreferencesAsync _preferencias;

  @override
  Future<AjustesRespaldo> leer() async => AjustesRespaldo(
    carpeta: await _preferencias.getString(_claveCarpeta),
    diasRecordatorio: await _preferencias.getInt(_claveDias) ?? 7,
    ultimo: DateTime.tryParse(
      await _preferencias.getString(_claveUltimo) ?? '',
    ),
    pospuestoHasta: DateTime.tryParse(
      await _preferencias.getString(_clavePospuesto) ?? '',
    ),
  );

  @override
  Future<void> guardar(AjustesRespaldo ajustes) async {
    await _texto(_claveCarpeta, ajustes.carpeta);
    await _preferencias.setInt(_claveDias, ajustes.diasRecordatorio);
    await _texto(_claveUltimo, ajustes.ultimo?.toIso8601String());
    await _texto(_clavePospuesto, ajustes.pospuestoHasta?.toIso8601String());
  }

  Future<void> _texto(String clave, String? valor) => valor == null
      ? _preferencias.remove(clave)
      : _preferencias.setString(clave, valor);
}
