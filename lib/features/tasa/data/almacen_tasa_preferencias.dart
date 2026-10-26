import 'package:inventario/features/tasa/domain/almacen_tasa.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlmacenTasaPreferencias implements AlmacenTasa {
  AlmacenTasaPreferencias([SharedPreferencesAsync? preferencias])
    : _preferencias = preferencias ?? SharedPreferencesAsync();

  static const _claveValor = 'tasa.bolivaresPorDolar';
  static const _claveFecha = 'tasa.fecha';

  final SharedPreferencesAsync _preferencias;

  @override
  Future<TasaCambio?> leer() async {
    final valor = await _preferencias.getInt(_claveValor);
    final fecha = DateTime.tryParse(
      await _preferencias.getString(_claveFecha) ?? '',
    );
    if (valor == null || fecha == null) return null;
    return TasaCambio(bolivaresPorDolar: valor, fecha: fecha);
  }

  @override
  Future<void> guardar(TasaCambio tasa) async {
    await _preferencias.setInt(_claveValor, tasa.bolivaresPorDolar);
    await _preferencias.setString(_claveFecha, tasa.fecha.toIso8601String());
  }
}
