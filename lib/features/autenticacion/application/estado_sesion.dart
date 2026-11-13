import 'package:inventario/features/autenticacion/domain/usuario.dart';

sealed class EstadoSesion {
  const EstadoSesion();
}

class SesionCerrada extends EstadoSesion {
  const SesionCerrada({this.pinIncorrecto = false, this.esperaHasta});

  /// True right after a failed attempt, so the screen can show why.
  final bool pinIncorrecto;

  /// After several wrong PINs, no attempt is taken until this moment, so
  /// nobody tries the 10.000 combinations at the counter. Null while free.
  final DateTime? esperaHasta;
}

class IniciandoSesion extends EstadoSesion {
  const IniciandoSesion();
}

class SesionAbierta extends EstadoSesion {
  const SesionAbierta(this.usuario);

  final Usuario usuario;
}
