import 'package:inventario/features/incidencias/domain/incidencia.dart';

sealed class ResultadoIncidencia {
  const ResultadoIncidencia();
}

class IncidenciaRegistrada extends ResultadoIncidencia {
  const IncidenciaRegistrada(this.incidencia);

  final Incidencia incidencia;
}

/// The stock changed while the window was open and there is no longer that
/// much of the brand to take out; nothing was saved.
class ExistenciaInsuficiente extends ResultadoIncidencia {
  const ExistenciaInsuficiente();
}
