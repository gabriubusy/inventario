import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Home-screen actions, each with its function key.
enum AccionRapida {
  salida(
    'Registrar salida',
    'Venta o despacho',
    Icons.upload_outlined,
    LogicalKeyboardKey.f1,
    'F1',
    destacada: true,
  ),
  entrada(
    'Registrar entrada',
    'Mercancía recibida',
    Icons.download_outlined,
    LogicalKeyboardKey.f2,
    'F2',
  ),
  merma(
    'Registrar merma',
    'Recortes, vencidos, pérdidas',
    Icons.delete_outline,
    LogicalKeyboardKey.f3,
    'F3',
  ),
  productos(
    'Productos',
    'Altas, precios y mínimos',
    Icons.inventory_2_outlined,
    LogicalKeyboardKey.f4,
    'F4',
  );

  const AccionRapida(
    this.titulo,
    this.descripcion,
    this.icono,
    this.tecla,
    this.atajo, {
    this.destacada = false,
  });

  final String titulo;
  final String descripcion;
  final IconData icono;
  final LogicalKeyboardKey tecla;
  final String atajo;

  /// The main action of the counter gets the filled style.
  final bool destacada;
}
