import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';

/// "Hay 2 pedidos por recibir" on the home screen: until the arrival is
/// confirmed that stock is not in the inventory.
class AvisoPedidos extends StatelessWidget {
  const AvisoPedidos({super.key, required this.compras, required this.onVer});

  final ControladorCompras compras;
  final VoidCallback onVer;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: compras,
      builder: (context, _) {
        final pendientes = compras.pendientes;
        if (pendientes.isEmpty) return const SizedBox.shrink();
        final alertas = context.coloresEstado;
        final espaciado = context.espaciado;
        final cuantos = pendientes.length == 1
            ? 'Hay un pedido por recibir'
            : 'Hay ${pendientes.length} pedidos por recibir';
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
                Icon(Icons.local_shipping_outlined, color: alertas.textoBajo),
                Expanded(
                  child: Text(
                    '$cuantos: su mercancía no cuenta en el inventario '
                    'hasta confirmar lo que llegó.',
                    style: TextStyle(color: alertas.textoBajo),
                  ),
                ),
                TextButton(
                  onPressed: onVer,
                  style: TextButton.styleFrom(
                    foregroundColor: alertas.textoBajo,
                  ),
                  child: Row(
                    spacing: espaciado.sm,
                    children: [
                      const Text('Ver pedidos'),
                      TeclaAtajo('Ctrl+P', color: alertas.textoBajo),
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
