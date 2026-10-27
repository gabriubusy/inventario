import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/repositorio_autenticacion.dart';
import 'package:inventario/features/autenticacion/domain/resultado_cambio_pin.dart';
import 'package:inventario/features/autenticacion/domain/resultado_inicio_sesion.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';

typedef CuentaEnMemoria = ({Usuario usuario, Pin pin});

/// Keeps the PIN in plain memory; meant for tests.
class RepositorioAutenticacionEnMemoria implements RepositorioAutenticacion {
  RepositorioAutenticacionEnMemoria(CuentaEnMemoria cuenta)
    : _usuario = cuenta.usuario,
      _pin = cuenta.pin;

  final Usuario _usuario;
  Pin _pin;

  @override
  Future<ResultadoInicioSesion> iniciarSesion({required Pin pin}) async {
    if (pin != _pin) return const PinIncorrecto();
    return InicioSesionCorrecto(_usuario);
  }

  @override
  Future<ResultadoCambioPin> cambiarPin({
    required Pin actual,
    required Pin nuevo,
  }) async {
    if (actual != _pin) return const PinActualIncorrecto();
    _pin = nuevo;
    return const PinCambiado();
  }
}
