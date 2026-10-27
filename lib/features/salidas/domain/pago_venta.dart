import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/numeros.dart';

/// One payment towards a sale, in its own currency.
class PagoVenta {
  const PagoVenta({
    required this.medio,
    required this.monto,
    this.referencia = '',
  });

  final MedioPago medio;

  /// Hundredths of the payment's currency ([MedioPago.moneda]).
  final int monto;

  /// Bank reference of a transfer or pago móvil; empty when not given.
  final String referencia;

  /// Its value in dollar hundredths at [tasa] (Bs per dollar, hundredths).
  int enDolares(int tasa) => switch (medio.moneda) {
    Moneda.dolares => monto,
    Moneda.bolivares => dividirRedondeando(monto * 100, tasa),
  };

  @override
  bool operator ==(Object other) =>
      other is PagoVenta &&
      other.medio == medio &&
      other.monto == monto &&
      other.referencia == referencia;

  @override
  int get hashCode => Object.hash(medio, monto, referencia);
}
