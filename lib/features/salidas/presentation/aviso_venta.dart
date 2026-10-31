import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/domain/resumen_cobro.dart';
import 'package:inventario/features/salidas/domain/venta.dart';
import 'package:inventario/features/salidas/presentation/aviso_salida.dart';

/// "Venta registrada · $ 53,27 · vuelto $ 6,73" with Deshacer.
void mostrarVentaCobrada(
  ScaffoldMessengerState mensajero,
  ControladorSalidas salidas,
  Venta venta,
) {
  final tasa = venta.tasa;
  final cobro = tasa == null
      ? null
      : ResumenCobro(total: venta.total, pagos: venta.pagos, tasa: tasa);
  final vuelto = cobro?.vuelto ?? 0;
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          [
            'Venta registrada',
            formatearDolares(venta.total),
            if (vuelto > 0)
              'vuelto ${formatearDolares(vuelto)} o '
                  '${formatearBolivares(cobro!.vueltoEnBolivares)}',
          ].join(' · '),
        ),
        persist: false,
        action: SnackBarAction(
          label: 'Deshacer (Ctrl+Z)',
          onPressed: () => unawaited(deshacerSalida(mensajero, salidas)),
        ),
      ),
    );
}
