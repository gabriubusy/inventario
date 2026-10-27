import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/salidas/domain/ticket.dart';
import 'package:inventario/features/salidas/presentation/pie_ticket.dart';
import 'package:inventario/features/salidas/presentation/tabla_ticket.dart';

/// The ticket under the product being added: its lines, then the total and
/// Cobrar. "Línea quitada · Alt+Z" appears while a removal can be undone.
class SeccionTicket extends StatelessWidget {
  const SeccionTicket({
    super.key,
    required this.ticket,
    required this.elegida,
    required this.hayQuitada,
    required this.aBolivares,
    required this.onElegir,
    required this.onQuitar,
    required this.onRecuperar,
    required this.onCobrar,
  });

  final Ticket ticket;
  final int? elegida;
  final bool hayQuitada;
  final int? Function(int dolares) aBolivares;
  final ValueChanged<int> onElegir;
  final ValueChanged<int> onQuitar;
  final VoidCallback onRecuperar;
  final VoidCallback onCobrar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final lineas = ticket.lineas.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: espaciado.md,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                lineas == 0
                    ? 'Ticket'
                    : 'Ticket · $lineas ${lineas == 1 ? 'producto' : 'productos'}',
                style: tema.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (hayQuitada)
              TextButton(
                onPressed: onRecuperar,
                child: const Text('Recuperar línea · Alt+Z'),
              ),
          ],
        ),
        TablaTicket(
          ticket: ticket,
          elegida: elegida,
          onElegir: onElegir,
          onQuitar: onQuitar,
        ),
        PieTicket(
          total: ticket.total,
          aBolivares: aBolivares,
          onCobrar: ticket.vacio ? null : onCobrar,
        ),
      ],
    );
  }
}
