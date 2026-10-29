import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/devoluciones_proveedor/application/controlador_devoluciones_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/devolucion_proveedor.dart';

/// "Devolución registrada · Distribuidora 1 · $ 64,48 · Descuenta" with
/// Deshacer.
void mostrarDevolucionRegistrada(
  ScaffoldMessengerState mensajero,
  ControladorDevolucionesProveedor devoluciones,
  DevolucionProveedor devolucion,
) {
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'Devolución registrada · ${devolucion.proveedor} · '
          '${formatearDolares(devolucion.total)} · '
          '${devolucion.compensacion.etiqueta}',
        ),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => unawaited(_deshacer(mensajero, devoluciones)),
        ),
      ),
    );
}

Future<void> _deshacer(
  ScaffoldMessengerState mensajero,
  ControladorDevolucionesProveedor devoluciones,
) async {
  final deshecha = await devoluciones.deshacer();
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          deshecha
              ? 'Devolución deshecha: el stock vuelve a como estaba'
              : 'No se pudo deshacer: algún producto cambió después',
        ),
      ),
    );
}
