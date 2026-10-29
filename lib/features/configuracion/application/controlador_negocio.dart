import 'package:flutter/foundation.dart';
import 'package:inventario/features/configuracion/domain/datos_negocio.dart';
import 'package:inventario/features/configuracion/domain/repositorio_negocio.dart';

/// The shop's details, read once at start and saved from Configuración.
class ControladorNegocio extends ChangeNotifier {
  ControladorNegocio(this._repositorio);

  final RepositorioNegocio _repositorio;
  DatosNegocio _datos = const DatosNegocio();

  DatosNegocio get datos => _datos;

  Future<void> cargar() async {
    _datos = await _repositorio.leer();
    notifyListeners();
  }

  Future<void> guardar(DatosNegocio datos) async {
    await _repositorio.guardar(datos);
    _datos = datos;
    notifyListeners();
  }
}
