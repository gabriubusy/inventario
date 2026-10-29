import 'package:inventario/features/configuracion/domain/ajustes_respaldo.dart';
import 'package:inventario/features/configuracion/domain/almacen_ajustes_respaldo.dart';

/// For tests.
class AlmacenAjustesRespaldoEnMemoria implements AlmacenAjustesRespaldo {
  AlmacenAjustesRespaldoEnMemoria([this._ajustes = const AjustesRespaldo()]);

  AjustesRespaldo _ajustes;

  @override
  Future<AjustesRespaldo> leer() async => _ajustes;

  @override
  Future<void> guardar(AjustesRespaldo ajustes) async => _ajustes = ajustes;
}
