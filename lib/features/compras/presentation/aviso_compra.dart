import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/domain/compra.dart';

/// "Pedido registrado · Distribuidora 1 · 3 productos · $ 331,60 · a
/// crédito hasta el 11 nov" with Deshacer.
void mostrarCompraRegistrada(
  ScaffoldMessengerState mensajero,
  ControladorCompras compras,
  Compra compra,
) {
  final vence = compra.vence;
  final pago = vence == null
      ? 'de contado (${compra.medio?.etiqueta ?? ''})'
      : 'a crédito hasta el ${formatearFechaCorta(vence, compras.hoy)}';
  final productos = compra.lineas.length == 1
      ? '1 producto'
      : '${compra.lineas.length} productos';
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'Pedido registrado · ${compra.proveedor} · $productos · '
          '${formatearDolares(compra.total)} · $pago',
        ),
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
  final deshecha = await compras.deshacerCompra();
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          deshecha
              ? 'Pedido deshecho: el stock vuelve a como estaba'
              : 'No se pudo deshacer: algún producto cambió después',
        ),
      ),
    );
}
