import 'package:inventario/features/tasa/domain/almacen_tasa.dart';
import 'package:inventario/features/tasa/domain/origen_tasa.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlmacenTasaPreferencias implements AlmacenTasa {
  AlmacenTasaPreferencias([SharedPreferencesAsync? preferencias])
    : _preferencias = preferencias ?? SharedPreferencesAsync();

  static const _claveValor = 'tasa.bolivaresPorDolar';
  static const _claveFecha = 'tasa.fecha';
  static const _claveOrigen = 'tasa.origen';
  static const _claveAnterior = 'tasa.anterior';

  final SharedPreferencesAsync _preferencias;

  @override
  Future<TasaCambio?> leer() async {
    final valor = await _preferencias.getInt(_claveValor);
    final fecha = DateTime.tryParse(
      await _preferencias.getString(_claveFecha) ?? '',
    );
    if (valor == null || fecha == null) return null;
    final origen = await _preferencias.getString(_claveOrigen);
    return TasaCambio(
      bolivaresPorDolar: valor,
      fecha: fecha,
      // Rates saved before the origin existed were typed by hand.
      origen: OrigenTasa.values.asNameMap()[origen] ?? OrigenTasa.manual,
      anterior: await _preferencias.getInt(_claveAnterior),
    );
  }

  @override
  Future<void> guardar(TasaCambio tasa) async {
    await _preferencias.setInt(_claveValor, tasa.bolivaresPorDolar);
    await _preferencias.setString(_claveFecha, tasa.fecha.toIso8601String());
    await _preferencias.setString(_claveOrigen, tasa.origen.name);
    if (tasa.anterior case final anterior?) {
      await _preferencias.setInt(_claveAnterior, anterior);
    } else {
      await _preferencias.remove(_claveAnterior);
    }
  }
}
