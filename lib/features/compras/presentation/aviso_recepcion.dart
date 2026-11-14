import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/estado_pedido.dart';

/// "Recibido · Frigorífico 1 · 3 líneas al stock · con diferencias" with
/// Deshacer, which takes the goods back out.
void mostrarRecepcionRegistrada(
  ScaffoldMessengerState mensajero,
  ControladorCompras compras,
  Compra compra, {
  required int lineas,
}) {
  final cuantas = lineas == 1 ? '1 línea' : '$lineas líneas';
  final estado = switch (compra.estado) {
    EstadoPedido.conDiferencias => 'con diferencias',
    EstadoPedido.parcial => 'quedan líneas por recibir',
    _ => 'completo',
  };
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'Recibido · ${compra.proveedor} · $cuantas al stock · $estado',
        ),
        persist: false,
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => unawaited(_deshacer(mensajero, compras)),
        ),
      ),
    );
}

Future<void> _deshacer(
  ScaffoldMessengerState mensajero,
  ControladorCompras compras,
) async {
  final deshecha = await compras.deshacerRecepcion();
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          deshecha
              ? 'Recepción deshecha: el pedido vuelve a estar por recibir'
              : 'No se pudo deshacer: algún producto cambió después',
        ),
      ),
    );
}
