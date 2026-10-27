import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/tasa/domain/origen_tasa.dart';

/// Bolívares per dollar on a given day. Prices are kept in dollars and
/// shown in bolívares with the rate, so a new rate needs no price changes.
class TasaCambio {
  const TasaCambio({
    required this.bolivaresPorDolar,
    required this.fecha,
    this.origen = OrigenTasa.manual,
    this.anterior,
  });

  /// In hundredths: 4000 is 40,00 Bs.
  final int bolivaresPorDolar;

  /// The day it applies to; only the day matters.
  final DateTime fecha;

  final OrigenTasa origen;

  /// The rate before this one, in hundredths; null when unknown.
  final int? anterior;

  bool esDelDia(DateTime dia) =>
      fecha.year == dia.year &&
      fecha.month == dia.month &&
      fecha.day == dia.day;

  /// [dolares] and the result are in hundredths.
  int aBolivares(int dolares) =>
      dividirRedondeando(dolares * bolivaresPorDolar, 100);

  /// Change from [anterior] in hundredths of a percent: 17 is +0,17 %.
  int? get variacion {
    final base = anterior;
    if (base == null || base <= 0) return null;
    return dividirRedondeando((bolivaresPorDolar - base) * 10000, base);
  }

  @override
  bool operator ==(Object other) =>
      other is TasaCambio &&
      other.bolivaresPorDolar == bolivaresPorDolar &&
      other.origen == origen &&
      other.anterior == anterior &&
      esDelDia(other.fecha);

  @override
  int get hashCode => Object.hash(
    bolivaresPorDolar,
    origen,
    anterior,
    fecha.year,
    fecha.month,
    fecha.day,
  );
}
