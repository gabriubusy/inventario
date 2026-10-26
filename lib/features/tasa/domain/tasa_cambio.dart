import 'package:inventario/core/numeros.dart';

/// Bolívares per dollar on a given day. Prices are kept in dollars and
/// shown in bolívares with the rate, so a new rate needs no price changes.
class TasaCambio {
  const TasaCambio({required this.bolivaresPorDolar, required this.fecha});

  /// In hundredths: 4000 is 40,00 Bs.
  final int bolivaresPorDolar;

  /// Only the day matters.
  final DateTime fecha;

  bool esDelDia(DateTime dia) =>
      fecha.year == dia.year &&
      fecha.month == dia.month &&
      fecha.day == dia.day;

  /// [dolares] and the result are in hundredths.
  int aBolivares(int dolares) =>
      dividirRedondeando(dolares * bolivaresPorDolar, 100);

  @override
  bool operator ==(Object other) =>
      other is TasaCambio &&
      other.bolivaresPorDolar == bolivaresPorDolar &&
      esDelDia(other.fecha);

  @override
  int get hashCode =>
      Object.hash(bolivaresPorDolar, fecha.year, fecha.month, fecha.day);
}
