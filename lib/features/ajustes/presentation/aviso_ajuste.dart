import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/features/ajustes/application/controlador_ajustes.dart';
import 'package:inventario/features/ajustes/domain/ajuste.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// "Merma registrada · Carne molida · Propia −0,4 kg" with Deshacer.
void mostrarAjusteRegistrado(
  ScaffoldMessengerState mensajero,
  ControladorAjustes ajustes,
  Producto producto,
  Ajuste ajuste,
) {
  final unidad = producto.forma.unidad;
  final cantidad = ajuste.piezas > 0
      ? '${textoPiezas(ajuste.piezas)} · ${unidad.formatear(ajuste.cantidad)}'
      : unidad.formatear(ajuste.cantidad);
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '${ajuste.tipo.etiqueta} registrada · ${producto.nombre} · '
          '${ajuste.marca} −$cantidad',
        ),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => unawaited(_deshacer(mensajero, ajustes)),
        ),
      ),
    );
}

Future<void> _deshacer(
  ScaffoldMessengerState mensajero,
  ControladorAjustes ajustes,
) async {
  final deshecho = await ajustes.deshacer();
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          deshecho
              ? 'Deshecho: el stock vuelve a como estaba'
              : 'No se pudo deshacer: el producto cambió después',
        ),
      ),
    );
}
