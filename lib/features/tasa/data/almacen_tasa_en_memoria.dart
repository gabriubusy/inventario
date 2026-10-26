import 'package:inventario/features/tasa/domain/almacen_tasa.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';

/// Forgets the rate on restart; meant for tests.
class AlmacenTasaEnMemoria implements AlmacenTasa {
  AlmacenTasaEnMemoria([this._tasa]);

  TasaCambio? _tasa;

  @override
  Future<TasaCambio?> leer() async => _tasa;

  @override
  Future<void> guardar(TasaCambio tasa) async => _tasa = tasa;
}
