import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// "No tienes Chuleta ahumada · tienes poco Carne molida" on the home screen,
/// in place of the stock cards, while something needs restocking.
class AvisoStock extends StatelessWidget {
  const AvisoStock({
    super.key,
    required this.existencias,
    required this.onPedido,
  });

  /// Names shown before "y N más".
  static const _nombresVisibles = 3;

  final ControladorExistencias existencias;
  final VoidCallback onPedido;

  static String _lista(List<Producto> productos, String y) {
    final nombres = productos.map((p) => p.nombre).toList();
    if (nombres.length <= _nombresVisibles) {
      return nombres.length == 1
          ? nombres.single
          : '${nombres.sublist(0, nombres.length - 1).join(', ')} $y '
                '${nombres.last}';
    }
    final resto = nombres.length - _nombresVisibles;
    return '${nombres.take(_nombresVisibles).join(', ')} y $resto más';
  }

  static String texto(List<Producto> reponer) {
    final agotados = [
      for (final p in reponer)
        if (p.estado == EstadoStock.agotado) p,
    ];
    final bajos = [
      for (final p in reponer)
        if (p.estado != EstadoStock.agotado) p,
    ];
    return [
      if (agotados.isNotEmpty) 'No tienes ${_lista(agotados, 'ni')}',
      if (bajos.isNotEmpty) 'tienes poco ${_lista(bajos, 'y')}',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: existencias,
      builder: (context, _) {
        final reponer = existencias.porReponer;
        if (reponer.isEmpty) return const SizedBox.shrink();
        final alertas = context.coloresEstado;
        final espaciado = context.espaciado;
        final agotado = reponer.first.estado == EstadoStock.agotado;
        final fondo = agotado ? alertas.fondoAgotado : alertas.fondoBajo;
        final tinta = agotado ? alertas.textoAgotado : alertas.textoBajo;
        final mensaje = texto(reponer);
        return ColoredBox(
          color: fondo,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: espaciado.xxl,
              vertical: espaciado.sm,
            ),
            child: Row(
              spacing: espaciado.md,
              children: [
                Icon(Icons.inventory_2_outlined, color: tinta),
                Expanded(
                  child: Text(
                    '${mensaje[0].toUpperCase()}${mensaje.substring(1)}.',
                    style: TextStyle(color: tinta),
                  ),
                ),
                TextButton(
                  onPressed: onPedido,
                  style: TextButton.styleFrom(foregroundColor: tinta),
                  child: Row(
                    spacing: espaciado.sm,
                    children: [
                      const Text('Hacer pedido'),
                      TeclaAtajo('F2', color: tinta),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
