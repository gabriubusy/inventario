/// Gets the official rate from outside the app, e.g. an internet service.
abstract interface class FuenteTasa {
  Future<ResultadoConsultaTasa> consultar();
}

sealed class ResultadoConsultaTasa {
  const ResultadoConsultaTasa();
}

class TasaObtenida extends ResultadoConsultaTasa {
  const TasaObtenida(this.bolivaresPorDolar, {this.anterior});

  /// The rate in force today, in hundredths like `TasaCambio`.
  final int bolivaresPorDolar;

  /// The one published before it, to show how much it moved.
  final int? anterior;
}

/// No internet, the service is down or it answered something unexpected.
class TasaNoDisponible extends ResultadoConsultaTasa {
  const TasaNoDisponible();
}
