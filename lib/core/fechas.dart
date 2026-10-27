const _dias = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Spanish long date without the year: "Sábado, 24 de octubre".
String formatearFechaLarga(DateTime fecha) =>
    '${_dias[fecha.weekday - 1]}, ${fecha.day} de ${_meses[fecha.month - 1]}';

/// Whole calendar days from [desde] to [hasta], ignoring the time of day.
int diasEntre(DateTime desde, DateTime hasta) {
  // UTC dates so a daylight-saving change can't cut a day short.
  final inicio = DateTime.utc(desde.year, desde.month, desde.day);
  final fin = DateTime.utc(hasta.year, hasta.month, hasta.day);
  return fin.difference(inicio).inDays;
}

/// "Hoy", "Ayer" or "18 oct" for a list where space is short.
String formatearFechaCorta(DateTime fecha, DateTime hoy) =>
    switch (diasEntre(fecha, hoy)) {
      0 => 'Hoy',
      1 => 'Ayer',
      _ => '${fecha.day} ${_meses[fecha.month - 1].substring(0, 3)}',
    };
