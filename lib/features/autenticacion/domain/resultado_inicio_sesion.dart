import 'package:inventario/features/autenticacion/domain/usuario.dart';

sealed class ResultadoInicioSesion {
  const ResultadoInicioSesion();
}

class InicioSesionCorrecto extends ResultadoInicioSesion {
  const InicioSesionCorrecto(this.usuario);

  final Usuario usuario;
}

class PinIncorrecto extends ResultadoInicioSesion {
  const PinIncorrecto();
}
