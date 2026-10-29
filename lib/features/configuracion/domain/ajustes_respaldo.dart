import 'package:inventario/core/fechas.dart';

/// Where backups go and when to remind about them; kept per computer.
class AjustesRespaldo {
  const AjustesRespaldo({
    this.carpeta,
    this.diasRecordatorio = 7,
    this.ultimo,
    this.pospuestoHasta,
  });

  /// Null until the user picks one (the first Ctrl+B asks).
  final String? carpeta;
  final int diasRecordatorio;

  /// When the last backup was made; null when there was never one.
  final DateTime? ultimo;

  /// "Mañana" on the reminder hides it until this day.
  final DateTime? pospuestoHasta;

  /// Days since the last backup; null when there was never one.
  int? diasSinRespaldo(DateTime hoy) {
    final ultimo = this.ultimo;
    return ultimo == null ? null : diasEntre(ultimo, hoy);
  }

  /// The home screen shows the reminder: never backed up, or not within the
  /// chosen days, and not put off for today.
  bool hayQueRecordar(DateTime hoy) {
    final pospuesto = pospuestoHasta;
    if (pospuesto != null && diasEntre(hoy, pospuesto) >= 0) return false;
    final dias = diasSinRespaldo(hoy);
    return dias == null || dias >= diasRecordatorio;
  }

  AjustesRespaldo copyWith({
    String? carpeta,
    int? diasRecordatorio,
    DateTime? ultimo,
    DateTime? pospuestoHasta,
  }) => AjustesRespaldo(
    carpeta: carpeta ?? this.carpeta,
    diasRecordatorio: diasRecordatorio ?? this.diasRecordatorio,
    ultimo: ultimo ?? this.ultimo,
    pospuestoHasta: pospuestoHasta ?? this.pospuestoHasta,
  );

  @override
  bool operator ==(Object other) =>
      other is AjustesRespaldo &&
      other.carpeta == carpeta &&
      other.diasRecordatorio == diasRecordatorio &&
      other.ultimo == ultimo &&
      other.pospuestoHasta == pospuestoHasta;

  @override
  int get hashCode =>
      Object.hash(carpeta, diasRecordatorio, ultimo, pospuestoHasta);
}
