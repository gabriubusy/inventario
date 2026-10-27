import 'package:inventario/features/reportes/domain/reporte.dart';

/// The report's table as CSV for Excel in Spanish: semicolons between
/// cells (the comma is the decimal mark) and a BOM so accents read right.
String csvDeReporte(Reporte reporte) {
  final lineas = [
    reporte.columnas,
    ...reporte.filas,
  ].map((fila) => fila.map(_celda).join(';'));
  return '﻿${lineas.join('\r\n')}\r\n';
}

String _celda(String texto) {
  final limpio = texto.replaceAll('−', '-');
  if (!limpio.contains(RegExp('[;"\r\n]'))) return limpio;
  return '"${limpio.replaceAll('"', '""')}"';
}
