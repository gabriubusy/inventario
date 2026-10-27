import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/domain/salida.dart';

/// "Salida registrada · Queso · Marca A −1 pieza · 0,84 kg · $ 4,37" with
/// Deshacer.
void mostrarSalidaRegistrada(
  ScaffoldMessengerState mensajero,
  ControladorSalidas salidas,
  Producto producto,
  Salida salida, {
  int? importe,
}) {
  final cantidad = producto.forma.unidad.formatear(salida.cantidad);
  final piezas = salida.piezas > 0 ? '${textoPiezas(salida.piezas)} · ' : '';
  final dinero = importe == null ? '' : ' · ${formatearDolares(importe)}';
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'Salida registrada · ${producto.nombre} · '
          '${salida.marca} −$piezas$cantidad$dinero',
        ),
        action: SnackBarAction(
          label: 'Deshacer (Ctrl+Z)',
          onPressed: () => unawaited(deshacerSalida(mensajero, salidas)),
        ),
      ),
    );
}

/// Undoes the last sale and says how it went.
Future<void> deshacerSalida(
  ScaffoldMessengerState mensajero,
  ControladorSalidas salidas,
) async {
  final deshecha = await salidas.deshacer();
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          deshecha
              ? 'Salida deshecha'
              : 'No se pudo deshacer: el producto cambió después',
        ),
      ),
    );
}
