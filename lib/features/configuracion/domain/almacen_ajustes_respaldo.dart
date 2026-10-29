import 'package:inventario/features/configuracion/domain/ajustes_respaldo.dart';

abstract interface class AlmacenAjustesRespaldo {
  Future<AjustesRespaldo> leer();

  Future<void> guardar(AjustesRespaldo ajustes);
}
