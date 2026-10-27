import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/textos_dinero.dart';
import 'package:inventario/features/caja/application/controlador_caja.dart';

Future<void> mostrarDialogoCerrarCaja(
  BuildContext context, {
  required ControladorCaja caja,
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoCerrarCaja(caja: caja),
);

/// Count what there is of each way of paying; the difference shows itself.
class DialogoCerrarCaja extends StatefulWidget {
  const DialogoCerrarCaja({super.key, required this.caja});

  static const _ancho = 720.0;

  final ControladorCaja caja;

  @override
  State<DialogoCerrarCaja> createState() => _DialogoCerrarCajaState();
}

class _DialogoCerrarCajaState extends State<DialogoCerrarCaja> {
  late final Map<MedioPago, int> _esperado = switch (widget.caja.abierta) {
    final caja? => widget.caja.saldosDe(caja),
    null => const {},
  };
  late final _contado = {
    for (final MapEntry(key: medio, value: monto) in _esperado.entries)
      medio: TextEditingController(
        text: formatDecimal(
          monto,
          decimales: decimalesDinero,
          minDecimales: decimalesDinero,
        ),
      )..addListener(() => setState(() {})),
  };
  final _nota = TextEditingController();
  var _guardando = false;

  @override
  void dispose() {
    for (final c in _contado.values) {
      c.dispose();
    }
    _nota.dispose();
    super.dispose();
  }

  int _leer(MedioPago medio) =>
      parseDecimal(_contado[medio]!.text, decimales: decimalesDinero) ?? 0;

  Future<void> _cerrar() async {
    if (_guardando) return;
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    await widget.caja.cerrar({
      for (final medio in _esperado.keys) medio: _leer(medio),
    }, nota: _nota.text.trim());
    if (!mounted) return;
    navegador.pop();
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Caja cerrada')));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final alertas = context.coloresEstado;
    final espaciado = context.espaciado;
    const cifras = [FontFeature.tabularFigures()];
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: {
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
              unawaited(_cerrar()),
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DialogoCerrarCaja._ancho),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(espaciado.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: espaciado.lg,
              children: [
                const EncabezadoDialogo(
                  titulo: 'Cerrar caja',
                  icono: Icons.lock_clock_outlined,
                ),
                Text(
                  'Cuenta lo que hay de cada forma de pago y escríbelo. Viene '
                  'con lo que debería haber; cambia solo lo que no cuadre.',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: colores.onSurfaceVariant,
                  ),
                ),
                for (final MapEntry(key: medio, value: esperado)
                    in _esperado.entries)
                  Row(
                    spacing: espaciado.md,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          medio.etiqueta,
                          style: tema.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Debería: ${textoEnMoneda(esperado, medio.moneda)}',
                          textAlign: TextAlign.right,
                          style: tema.textTheme.bodyMedium?.copyWith(
                            fontFeatures: cifras,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _contado[medio],
                          textAlign: TextAlign.right,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp('[0-9.,-]'),
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Contado',
                            isDense: true,
                            prefixText: medio.moneda == Moneda.dolares
                                ? r'$ '
                                : 'Bs ',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Builder(
                          builder: (context) {
                            final diferencia = _leer(medio) - esperado;
                            return Text(
                              diferencia == 0
                                  ? 'Cuadra'
                                  : diferencia < 0
                                  ? 'Faltan ${textoEnMoneda(-diferencia, medio.moneda)}'
                                  : 'Sobran ${textoEnMoneda(diferencia, medio.moneda)}',
                              textAlign: TextAlign.right,
                              style: tema.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFeatures: cifras,
                                color: diferencia == 0
                                    ? colores.tertiary
                                    : alertas.textoAgotado,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                if (_esperado.isEmpty)
                  Text(
                    'No se movió dinero en esta caja.',
                    style: tema.textTheme.bodyMedium,
                  ),
                TextField(
                  controller: _nota,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nota del cierre (opcional)',
                    hintText: 'Faltan Bs 120: vuelto mal dado',
                  ),
                  onSubmitted: (_) => unawaited(_cerrar()),
                ),
                BotonesCrear(
                  etiqueta: 'Cerrar caja',
                  atajo: 'Ctrl+S',
                  guardando: _guardando,
                  onCrear: () => unawaited(_cerrar()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
