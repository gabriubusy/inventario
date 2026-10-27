import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';

/// Alt+A, S, D, F, G pick each way of paying, in declaration order.
const teclasMedio = [
  LogicalKeyboardKey.keyA,
  LogicalKeyboardKey.keyS,
  LogicalKeyboardKey.keyD,
  LogicalKeyboardKey.keyF,
  LogicalKeyboardKey.keyG,
];
const _letras = ['A', 'S', 'D', 'F', 'G'];

/// Cash (Alt+Q) with how it was paid, or credit (Alt+W) with its due date.
class SeccionPagoCompra extends StatelessWidget {
  const SeccionPagoCompra({
    super.key,
    required this.credito,
    required this.dias,
    required this.vence,
    required this.medio,
    required this.onCredito,
    required this.onMedio,
  });

  final bool credito;
  final TextEditingController dias;

  /// The due date for the days typed; null while they are not valid.
  final DateTime? vence;
  final MedioPago medio;
  final ValueChanged<bool> onCredito;
  final ValueChanged<MedioPago> onMedio;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final vence = this.vence;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: espaciado.md,
      children: [
        ExcludeFocus(
          child: Row(
            spacing: espaciado.sm,
            children: [
              Expanded(
                child: OpcionSeleccionable(
                  titulo: 'De contado',
                  detalle: 'Se paga ahora · Alt+Q',
                  elegida: !credito,
                  onPulsar: () => onCredito(false),
                ),
              ),
              Expanded(
                child: OpcionSeleccionable(
                  titulo: 'A crédito',
                  detalle: 'Queda por pagar · Alt+W',
                  elegida: credito,
                  onPulsar: () => onCredito(true),
                ),
              ),
            ],
          ),
        ),
        if (credito)
          Row(
            spacing: espaciado.md,
            children: [
              SizedBox(
                width: 120,
                child: TextField(
                  controller: dias,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Vence en',
                    suffixText: 'días',
                    isDense: true,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  vence == null
                      ? 'Escribe los días'
                      : 'el ${formatearFechaLarga(vence).toLowerCase()}',
                  style: tema.textTheme.bodyMedium,
                ),
              ),
            ],
          )
        else
          ExcludeFocus(
            child: Wrap(
              spacing: espaciado.sm,
              runSpacing: espaciado.sm,
              children: [
                for (final (i, m) in MedioPago.paraProveedores.indexed)
                  ChoiceChip(
                    label: Text('${m.etiqueta} · Alt+${_letras[i]}'),
                    selected: m == medio,
                    showCheckmark: false,
                    onSelected: (_) => onMedio(m),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
