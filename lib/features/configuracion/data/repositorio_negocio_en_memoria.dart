import 'package:inventario/features/configuracion/domain/datos_negocio.dart';
import 'package:inventario/features/configuracion/domain/repositorio_negocio.dart';

/// For tests.
class RepositorioNegocioEnMemoria implements RepositorioNegocio {
  RepositorioNegocioEnMemoria([this._datos = const DatosNegocio()]);

  DatosNegocio _datos;

  @override
  Future<DatosNegocio> leer() async => _datos;

  @override
  Future<void> guardar(DatosNegocio datos) async => _datos = datos;
}
