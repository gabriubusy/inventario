import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/rejilla_adaptable.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/inicio/presentation/cifra_del_dia.dart';
import 'package:inventario/features/movimientos/domain/resumen_dia.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// Sold today, kilos sold, the best seller and how many need restocking.
class ResumenDelDia extends StatelessWidget {
  const ResumenDelDia({
    super.key,
    required this.resumen,
    required this.porReponer,
    required this.aBolivares,
  });

  /// Room for "63.353,22 Bs · 5 ventas" or a long product name.
  static const _anchoMinimo = 260.0;

  final ResumenDia resumen;
  final List<Producto> porReponer;
  final int? Function(int) aBolivares;

  String get _detalleVendido {
    final ventas = resumen.ventas == 1 ? '1 venta' : '${resumen.ventas} ventas';
    final bolivares = aBolivares(resumen.vendido);
    return bolivares == null
        ? ventas
        : '${formatearBolivares(bolivares)} · $ventas';
  }

  String get _detalleReponer {
    final agotados = porReponer
        .where((p) => p.estado == EstadoStock.agotado)
        .length;
    final bajos = porReponer.length - agotados;
    if (porReponer.isEmpty) return 'Todo por encima del mínimo';
    return [
      if (agotados > 0) '$agotados ${agotados == 1 ? 'agotado' : 'agotados'}',
      if (bajos > 0) '$bajos ${bajos == 1 ? 'bajo' : 'bajos'}',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final mas = resumen.masVendido;
    final unidades = resumen.unidades;
    return RejillaAdaptable(
      anchoMinimo: _anchoMinimo,
      espacio: context.espaciado.md,
      children: [
        CifraDelDia(
          titulo: 'Vendido hoy',
          valor: formatearDolares(resumen.vendido),
          detalle: _detalleVendido,
        ),
        CifraDelDia(
          titulo: 'Kilos vendidos',
          valor: UnidadBase.kg.formatear(resumen.gramos),
          detalle: unidades == 0
              ? 'Por peso, en piezas y al kilo'
              : '+ ${formatDecimal(unidades, decimales: 0)} und',
        ),
        CifraDelDia(
          titulo: 'Más vendido',
          valor: mas?.producto ?? '—',
          detalle: mas == null
              ? 'Aún no hay ventas hoy'
              : '${mas.unidad.formatear(mas.cantidad)} · '
                    '${formatearDolares(mas.importe)}',
        ),
        CifraDelDia(
          titulo: 'Hay que reponer',
          valor: '${porReponer.length}',
          detalle: _detalleReponer,
          color: porReponer.isEmpty ? null : context.coloresEstado.textoAgotado,
        ),
      ],
    );
  }
}
