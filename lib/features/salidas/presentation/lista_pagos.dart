import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';
import 'package:inventario/features/salidas/presentation/textos_cobro.dart';

/// Payments already added to a mixed payment, each removable.
class ListaPagos extends StatelessWidget {
  const ListaPagos({super.key, required this.pagos, required this.onQuitar});

  final List<PagoVenta> pagos;
  final ValueChanged<int> onQuitar;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final espaciado = context.espaciado;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colores.outlineVariant),
        borderRadius: BorderRadius.circular(espaciado.md),
      ),
      child: Column(
        children: [
          for (final (i, pago) in pagos.indexed)
            Padding(
              padding: EdgeInsets.only(left: espaciado.lg),
              child: Row(
                children: [
                  Expanded(child: Text(textoPago(pago))),
                  ExcludeFocus(
                    child: IconButton(
                      tooltip: 'Quitar ${pago.medio.etiqueta}',
                      icon: const Icon(Icons.close),
                      onPressed: () => onQuitar(i),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
