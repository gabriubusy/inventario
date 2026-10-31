import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/entradas/domain/entrada.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// "Entrada registrada · Queso · Marca A +6 piezas · 4,9 kg" with Deshacer.
void mostrarEntradaRegistrada(
  ScaffoldMessengerState mensajero,
  ControladorEntradas entradas,
  Producto producto,
  Entrada entrada,
) {
  final unidad = producto.forma.unidad;
  final cantidad = producto.forma.cuentaPiezas
      ? '${textoPiezas(entrada.piezas)} · ${unidad.formatear(entrada.cantidad)}'
      : unidad.formatear(entrada.cantidad);
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'Entrada registrada · ${producto.nombre} · '
          '${entrada.marca} +$cantidad',
        ),
        persist: false,
        action: SnackBarAction(
          label: 'Deshacer (Ctrl+Z)',
          onPressed: () => unawaited(deshacerEntrada(mensajero, entradas)),
        ),
      ),
    );
}

/// Undoes the last entry and says how it went.
Future<void> deshacerEntrada(
  ScaffoldMessengerState mensajero,
  ControladorEntradas entradas,
) async {
  final deshecha = await entradas.deshacer();
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          deshecha
              ? 'Entrada deshecha'
              : 'No se pudo deshacer: el producto cambió después',
        ),
      ),
    );
}
