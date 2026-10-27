import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/resultado_cambio_pin.dart';
import 'package:inventario/features/autenticacion/domain/resultado_inicio_sesion.dart';

/// The app has a single user, so only the PIN is checked.
abstract interface class RepositorioAutenticacion {
  Future<ResultadoInicioSesion> iniciarSesion({required Pin pin});

  /// Replaces the PIN only when [actual] is the right one.
  Future<ResultadoCambioPin> cambiarPin({
    required Pin actual,
    required Pin nuevo,
  });
}
