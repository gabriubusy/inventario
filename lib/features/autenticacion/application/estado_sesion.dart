import 'package:inventario/features/autenticacion/domain/usuario.dart';

sealed class EstadoSesion {
  const EstadoSesion();
}

class SesionCerrada extends EstadoSesion {
  const SesionCerrada({this.pinIncorrecto = false});

  /// True right after a failed attempt, so the screen can show why.
  final bool pinIncorrecto;
}

class IniciandoSesion extends EstadoSesion {
  const IniciandoSesion();
}

class SesionAbierta extends EstadoSesion {
  const SesionAbierta(this.usuario);

  final Usuario usuario;
}
