import 'package:inventario/features/incidencias/domain/incidencia.dart';

sealed class EstadoIncidencias {
  const EstadoIncidencias();
}

class CargandoIncidencias extends EstadoIncidencias {
  const CargandoIncidencias();
}

class IncidenciasCargadas extends EstadoIncidencias {
  const IncidenciasCargadas(this.incidencias);

  /// Newest first.
  final List<Incidencia> incidencias;
}
