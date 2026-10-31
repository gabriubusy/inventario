import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/caja/application/controlador_caja.dart';

/// "La caja de hoy no está abierta" on the home screen, until it is.
class AvisoCaja extends StatelessWidget {
  const AvisoCaja({super.key, required this.caja, required this.onAbrir});

  final ControladorCaja caja;
  final VoidCallback onAbrir;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: caja,
      builder: (context, _) {
        if (!caja.faltaAbrirHoy) return const SizedBox.shrink();
        final alertas = context.coloresEstado;
        final espaciado = context.espaciado;
        return ColoredBox(
          color: alertas.fondoBajo,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: espaciado.xxl,
              vertical: espaciado.sm,
            ),
            child: Row(
              spacing: espaciado.md,
              children: [
                Icon(Icons.point_of_sale_outlined, color: alertas.textoBajo),
                Expanded(
                  child: Text(
                    'La caja de hoy no está abierta: lo que vendas no se '
                    'cuadrará al cerrar.',
                    style: TextStyle(color: alertas.textoBajo),
                  ),
                ),
                TextButton(
                  onPressed: onAbrir,
                  style: TextButton.styleFrom(
                    foregroundColor: alertas.textoBajo,
                  ),
                  child: Row(
                    spacing: espaciado.sm,
                    children: [
                      const Text('Abrir caja'),
                      TeclaAtajo('F11', color: alertas.textoBajo),
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
