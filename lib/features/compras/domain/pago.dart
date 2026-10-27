import 'package:inventario/core/medio_pago.dart';

/// A payment, whole or partial, of an invoice bought on credit.
class Pago {
  const Pago({
    this.id = '',
    required this.compraId,
    required this.fecha,
    required this.medio,
    required this.monto,
    required this.entregado,
    this.tasa,
    this.referencia = '',
  });

  /// Empty until the repository stores it.
  final String id;
  final String compraId;
  final DateTime fecha;
  final MedioPago medio;

  /// What it takes off the debt, in dollar hundredths.
  final int monto;

  /// What was handed over, in hundredths of the medio's currency.
  final int entregado;

  /// Bs per dollar (hundredths) used to convert a payment in bolívares.
  final int? tasa;

  /// Transfer or mobile-payment number; empty when there is none.
  final String referencia;

  Pago conId(String id) => Pago(
    id: id,
    compraId: compraId,
    fecha: fecha,
    medio: medio,
    monto: monto,
    entregado: entregado,
    tasa: tasa,
    referencia: referencia,
  );

  @override
  bool operator ==(Object other) =>
      other is Pago &&
      other.id == id &&
      other.compraId == compraId &&
      other.fecha == fecha &&
      other.medio == medio &&
      other.monto == monto &&
      other.entregado == entregado &&
      other.tasa == tasa &&
      other.referencia == referencia;

  @override
  int get hashCode => Object.hash(
    id,
    compraId,
    fecha,
    medio,
    monto,
    entregado,
    tasa,
    referencia,
  );
}
