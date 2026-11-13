import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/core/textos_dinero.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/gastos/domain/gasto.dart';

/// "Gasto registrado · Hielo · Bs 120,00" with Deshacer.
void mostrarGastoRegistrado(
  ScaffoldMessengerState mensajero,
  ControladorGastos gastos,
  Gasto gasto,
) {
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '${gasto.esIngreso ? 'Ingreso' : 'Gasto'} registrado · '
          '${gasto.categoria.etiqueta} · '
          '${textoEnMoneda(gasto.monto, gasto.medio.moneda)}',
        ),
        persist: false,
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => unawaited(deshacerGasto(mensajero, gastos, gasto)),
        ),
      ),
    );
}

/// Undoes that expense and says how it went.
Future<void> deshacerGasto(
  ScaffoldMessengerState mensajero,
  ControladorGastos gastos,
  Gasto gasto,
) async {
  final deshecho = await gastos.deshacer(gasto);
  final que = gasto.esIngreso ? 'ingreso' : 'gasto';
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          deshecho
              ? '${que[0].toUpperCase()}${que.substring(1)} deshecho'
              : 'No se pudo deshacer: hubo otro movimiento de dinero después',
        ),
      ),
    );
}
