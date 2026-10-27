import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

/// Column widths shared by the header and every row of the incidents table.
class ColumnasIncidencia extends StatelessWidget {
  const ColumnasIncidencia({
    super.key,
    required this.mostrarProveedor,
    required this.fecha,
    required this.proveedor,
    required this.producto,
    required this.tipo,
    required this.afectado,
    required this.estado,
  });

  static const _anchoFecha = 64.0;
  static const _anchoEstado = 120.0;

  /// Hidden inside a supplier's card, where it would repeat itself.
  final bool mostrarProveedor;
  final Widget fecha;
  final Widget proveedor;
  final Widget producto;
  final Widget tipo;
  final Widget afectado;
  final Widget estado;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.espaciado.md,
      children: [
        SizedBox(width: _anchoFecha, child: fecha),
        if (mostrarProveedor) Expanded(flex: 3, child: proveedor),
        Expanded(flex: 4, child: producto),
        Expanded(flex: 3, child: tipo),
        Expanded(flex: 3, child: afectado),
        SizedBox(width: _anchoEstado, child: estado),
      ],
    );
  }
}
