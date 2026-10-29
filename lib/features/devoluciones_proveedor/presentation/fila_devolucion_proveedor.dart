import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/compensacion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/devolucion_proveedor.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// Widths shared by the header and every row of the returns table.
class ColumnasDevolucion extends StatelessWidget {
  const ColumnasDevolucion({super.key, required this.celdas});

  static const _flex = [2, 3, 7, 2, 4];

  /// Date, supplier, what went back, value, how it was made up.
  final List<Widget> celdas;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.espaciado.md,
      children: [
        for (final (i, celda) in celdas.indexed)
          Expanded(flex: _flex[i], child: celda),
      ],
    );
  }
}

class FilaDevolucionProveedor extends StatelessWidget {
  const FilaDevolucionProveedor({
    super.key,
    required this.devolucion,
    required this.hoy,
    required this.factura,
    required this.elegida,
    required this.onElegir,
  });

  final DevolucionProveedor devolucion;
  final DateTime hoy;

  /// The discounted invoice's number, when there is one.
  final String? factura;
  final bool elegida;
  final VoidCallback onElegir;

  String get _que => [
    for (final l in devolucion.lineas)
      [
        l.producto,
        if (l.piezas > 0) textoPiezas(l.piezas),
        l.forma.unidad.formatear(l.cantidad),
      ].join(' '),
  ].join(' · ');

  String get _compensa {
    final d = devolucion;
    return switch (d.compensacion) {
      Compensacion.descuento =>
        factura == null || factura!.isEmpty
            ? 'Descuento en factura'
            : 'Descuento · factura $factura',
      Compensacion.dinero => 'Devolvió dinero · ${d.medio?.etiqueta ?? ''}',
      Compensacion.repone =>
        d.repuesta == null
            ? 'Repone · pendiente'
            : 'Repuso el ${formatearFechaCorta(d.repuesta!, hoy)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    const cifras = [FontFeature.tabularFigures()];
    final base = tema.textTheme.bodyMedium?.copyWith(fontFeatures: cifras);
    final suave = base?.copyWith(color: colores.onSurfaceVariant);
    return Semantics(
      selected: elegida,
      button: true,
      child: InkWell(
        onTap: onElegir,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: elegida ? colores.primary.withValues(alpha: 0.06) : null,
            border: Border(
              top: BorderSide(color: colores.outlineVariant),
              left: BorderSide(
                color: elegida ? colores.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(espaciado.md),
            child: ColumnasDevolucion(
              celdas: [
                Text(formatearFechaCorta(devolucion.fecha, hoy), style: suave),
                Text(
                  devolucion.proveedor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: base?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$_que · ${devolucion.motivo.etiqueta}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: base,
                ),
                Text(
                  formatearDolares(devolucion.total),
                  textAlign: TextAlign.right,
                  style: base?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  _compensa,
                  style: base?.copyWith(
                    color: devolucion.pendiente
                        ? context.coloresEstado.textoBajo
                        : colores.onSurfaceVariant,
                    fontWeight: devolucion.pendiente ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
