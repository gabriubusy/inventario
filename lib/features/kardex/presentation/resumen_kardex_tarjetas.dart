import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/inicio/presentation/cifra_del_dia.dart';
import 'package:inventario/features/kardex/domain/resumen_kardex.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// What there is now, and what came in, was sold and was lost.
class ResumenKardexTarjetas extends StatelessWidget {
  const ResumenKardexTarjetas({
    super.key,
    required this.producto,
    required this.resumen,
    required this.periodo,
  });

  final Producto producto;
  final ResumenKardex resumen;

  /// "7 días", shown in each title.
  final String periodo;

  @override
  Widget build(BuildContext context) {
    final unidad = producto.forma.unidad;
    String veces(int n, String una, String varias) =>
        n == 1 ? '1 $una' : '$n $varias';
    return Row(
      spacing: context.espaciado.md,
      children: [
        Expanded(
          child: CifraDelDia(
            titulo: 'Hay ahora',
            valor: textoStock(producto),
            detalle: '${textoMinimo(producto)} · ${producto.estado.etiqueta}',
          ),
        ),
        Expanded(
          child: CifraDelDia(
            titulo: 'Entró ($periodo)',
            valor: '+${unidad.formatear(resumen.entro)}',
            detalle: veces(resumen.entradas, 'movimiento', 'movimientos'),
          ),
        ),
        Expanded(
          child: CifraDelDia(
            titulo: 'Vendido ($periodo)',
            valor: '−${unidad.formatear(resumen.vendido)}',
            detalle: veces(resumen.ventas, 'venta', 'ventas'),
          ),
        ),
        Expanded(
          child: CifraDelDia(
            titulo: 'Perdido ($periodo)',
            valor: '−${unidad.formatear(resumen.perdido)}',
            detalle: 'Merma, robo, conteo e incidencias',
            color: resumen.perdido > 0
                ? context.coloresEstado.textoAgotado
                : null,
          ),
        ),
      ],
    );
  }
}
