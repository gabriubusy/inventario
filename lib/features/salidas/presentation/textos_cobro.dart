import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';

/// "$ 20,00" or "30.000,00 Bs", in the payment's own currency.
String textoMonto(MedioPago medio, int monto) => switch (medio.moneda) {
  Moneda.dolares => formatearDolares(monto),
  Moneda.bolivares => formatearBolivares(monto),
};

/// "Pago móvil · 30.000,00 Bs · ref. 004581"
String textoPago(PagoVenta pago) => [
  pago.medio.etiqueta,
  textoMonto(pago.medio, pago.monto),
  if (pago.referencia.isNotEmpty) 'ref. ${pago.referencia}',
].join(' · ');
