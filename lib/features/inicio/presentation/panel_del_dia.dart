import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/inicio/presentation/hay_que_reponer.dart';
import 'package:inventario/features/inicio/presentation/resumen_del_dia.dart';
import 'package:inventario/features/inicio/presentation/ultimas_ventas.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/por_reponer.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';

/// The day at a glance: figures, latest sales and what to restock.
class PanelDelDia extends StatelessWidget {
  const PanelDelDia({
    super.key,
    required this.movimientos,
    required this.existencias,
    required this.tasa,
    required this.onVerVentas,
  });

  /// Below this the restock list goes under the sales, so neither is cut.
  static const _anchoDosColumnas = 1000.0;

  final ControladorMovimientos movimientos;
  final ControladorExistencias existencias;
  final ControladorTasa tasa;
  final VoidCallback onVerVentas;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return ListenableBuilder(
      listenable: Listenable.merge([movimientos, existencias, tasa]),
      builder: (context, _) {
        final reponer = porReponer(existencias.productos);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: espaciado.lg,
          children: [
            ResumenDelDia(
              resumen: movimientos.resumenDeHoy,
              porReponer: reponer,
              aBolivares: tasa.aBolivares,
            ),
            LayoutBuilder(
              builder: (context, limites) {
                final ventas = UltimasVentas(
                  ventas: movimientos.ultimasVentas(),
                  onVerTodas: onVerVentas,
                );
                final hayQueReponer = HayQueReponer(productos: reponer);
                if (limites.maxWidth < _anchoDosColumnas) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: espaciado.lg,
                    children: [ventas, hayQueReponer],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: espaciado.lg,
                  children: [
                    Expanded(flex: 3, child: ventas),
                    Expanded(flex: 2, child: hayQueReponer),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
