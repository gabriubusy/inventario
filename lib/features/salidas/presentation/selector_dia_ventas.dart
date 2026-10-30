import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/fechas.dart';

/// ‹ Hoy Ayer ›, plus the long date of the day shown; the arrows' hover
/// help tells Alt+← and Alt+→.
class SelectorDiaVentas extends StatelessWidget {
  const SelectorDiaVentas({
    super.key,
    required this.dia,
    required this.hoy,
    required this.onCambiar,
  });

  final DateTime dia;
  final DateTime hoy;
  final ValueChanged<DateTime> onCambiar;

  void _mover(int dias) =>
      onCambiar(DateTime(dia.year, dia.month, dia.day + dias));

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final atras = diasEntre(dia, hoy);
    final ayer = DateTime(hoy.year, hoy.month, hoy.day - 1);
    return Wrap(
      spacing: espaciado.sm,
      runSpacing: espaciado.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          tooltip: 'Día anterior (Alt+←)',
          onPressed: () => _mover(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        for (final (texto, fecha) in [('Hoy', hoy), ('Ayer', ayer)])
          ChoiceChip(
            label: Text(texto),
            selected: diasEntre(dia, fecha) == 0,
            onSelected: (_) => onCambiar(fecha),
          ),
        IconButton(
          tooltip: 'Día siguiente (Alt+→)',
          onPressed: atras > 0 ? () => _mover(1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
        Text(
          formatearFechaLarga(dia),
          style: tema.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
