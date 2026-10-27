import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/numeros.dart';

/// The opening cash, in dollars and bolívares; empty means none.
class AbrirCaja extends StatefulWidget {
  const AbrirCaja({super.key, required this.onAbrir, this.resumenAnterior});

  final void Function({required int dolares, required int bolivares}) onAbrir;

  /// How the last till ended, shown as a reminder; null when none.
  final String? resumenAnterior;

  @override
  State<AbrirCaja> createState() => _AbrirCajaState();
}

class _AbrirCajaState extends State<AbrirCaja> {
  final _dolares = TextEditingController();
  final _bolivares = TextEditingController();

  @override
  void dispose() {
    _dolares.dispose();
    _bolivares.dispose();
    super.dispose();
  }

  int _leer(TextEditingController c) =>
      parseDecimal(c.text, decimales: decimalesDinero) ?? 0;

  void _abrir() =>
      widget.onAbrir(dolares: _leer(_dolares), bolivares: _leer(_bolivares));

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final anterior = widget.resumenAnterior;
    InputDecoration decoracion(String etiqueta, String prefijo) =>
        InputDecoration(labelText: etiqueta, prefixText: prefijo);
    final formato = [FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))];
    return Card(
      child: Padding(
        padding: EdgeInsets.all(espaciado.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: espaciado.lg,
          children: [
            Text(
              'Abrir la caja de hoy',
              style: tema.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Cuenta el efectivo con que empiezas el día. Si no hay, '
              'deja vacío.',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            if (anterior != null)
              Text(anterior, style: tema.textTheme.bodySmall),
            Row(
              spacing: espaciado.md,
              children: [
                Expanded(
                  child: TextField(
                    controller: _dolares,
                    autofocus: true,
                    textAlign: TextAlign.right,
                    inputFormatters: formato,
                    textInputAction: TextInputAction.next,
                    decoration: decoracion('Efectivo en dólares', r'$ '),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _bolivares,
                    textAlign: TextAlign.right,
                    inputFormatters: formato,
                    decoration: decoracion('Efectivo en bolívares', 'Bs '),
                    onSubmitted: (_) => _abrir(),
                  ),
                ),
              ],
            ),
            BotonesCrear(
              etiqueta: 'Abrir caja',
              guardando: false,
              onCrear: _abrir,
            ),
          ],
        ),
      ),
    );
  }
}
