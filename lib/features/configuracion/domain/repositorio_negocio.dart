import 'package:inventario/features/configuracion/domain/datos_negocio.dart';

abstract interface class RepositorioNegocio {
  /// Empty details until they are first saved.
  Future<DatosNegocio> leer();

  Future<void> guardar(DatosNegocio datos);
}
