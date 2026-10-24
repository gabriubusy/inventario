import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/repositorio_autenticacion.dart';
import 'package:inventario/features/autenticacion/domain/resultado_inicio_sesion.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';

typedef CuentaEnMemoria = ({Usuario usuario, Pin pin});

/// Stand-in until local persistence is decided; the PIN is kept in plain text.
class RepositorioAutenticacionEnMemoria implements RepositorioAutenticacion {
  const RepositorioAutenticacionEnMemoria(this._cuenta);

  final CuentaEnMemoria _cuenta;

  @override
  Future<ResultadoInicioSesion> iniciarSesion({required Pin pin}) async {
    if (pin != _cuenta.pin) return const PinIncorrecto();
    return InicioSesionCorrecto(_cuenta.usuario);
  }
}
