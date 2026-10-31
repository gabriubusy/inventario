import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/productos/presentation/campo_cantidad.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';

Future<void> mostrarDialogoTasa(
  BuildContext context,
  ControladorTasa controlador,
) => showDialog<void>(
  context: context,
  builder: (_) => DialogoTasa(controlador: controlador),
);

/// Today's bolívares per dollar; Enter saves.
class DialogoTasa extends StatefulWidget {
  const DialogoTasa({super.key, required this.controlador});

  static const _ancho = 400.0;

  final ControladorTasa controlador;

  @override
  State<DialogoTasa> createState() => _DialogoTasaState();
}

class _DialogoTasaState extends State<DialogoTasa> {
  final _formulario = GlobalKey<FormState>();
  final _valor = TextEditingController();
  final _foco = FocusNode();
  var _guardando = false;
  var _enCero = false;

  /// The value already warned about as a big jump; Enter again saves it.
  int? _avisado;

  /// More than this share (hundredths of a percent) from the last rate is
  /// probably a typo, like 3650 for 36,50.
  static const _saltoRaro = 1000;

  @override
  void initState() {
    super.initState();
    // The last rate comes written and selected: a small change is quick,
    // a new one simply replaces it.
    if (widget.controlador.tasa case final anterior?) {
      _valor.text = formatDecimal(
        anterior.bolivaresPorDolar,
        decimales: decimalesDinero,
        minDecimales: decimalesDinero,
      );
      _valor.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _valor.text.length,
      );
    }
  }

  @override
  void dispose() {
    _valor.dispose();
    _foco.dispose();
    super.dispose();
  }

  /// "Cambia 310 % respecto a la última" when it looks like a typo.
  String? get _aviso {
    final anterior = widget.controlador.tasa?.bolivaresPorDolar;
    final valor = CampoCantidad.leer(_valor, decimalesDinero);
    if (anterior == null || anterior == 0 || valor <= 0) return null;
    final cambio = dividirRedondeando(
      (valor - anterior).abs() * 10000,
      anterior,
    );
    if (cambio <= _saltoRaro) return null;
    return 'Cambia ${formatDecimal(cambio, decimales: 2)} % respecto a la '
        'última. ¿Está bien escrita? Enter otra vez para guardarla.';
  }

  Future<void> _guardar() async {
    if (_guardando || !(_formulario.currentState?.validate() ?? false)) return;
    final valor = CampoCantidad.leer(_valor, decimalesDinero);
    if (valor <= 0) {
      setState(() => _enCero = true);
      return;
    }
    if (_aviso != null && _avisado != valor) {
      setState(() => _avisado = valor);
      // Enter left the field; it comes back so a second Enter confirms.
      _foco.requestFocus();
      return;
    }
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    await widget.controlador.guardar(valor);
    if (!mounted) return;
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Tasa guardada · 1 \$ = ${formatearBolivares(valor)}'),
        ),
      );
    navegador.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final anterior = widget.controlador.tasa;
    final estilo = tema.textTheme.bodySmall?.copyWith(
      color: colores.onSurfaceVariant,
    );
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: DialogoTasa._ancho),
        child: Padding(
          padding: EdgeInsets.all(espaciado.xl),
          child: Form(
            key: _formulario,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: espaciado.lg,
              children: [
                const EncabezadoDialogo(
                  titulo: 'Tasa de hoy',
                  icono: Icons.currency_exchange,
                ),
                Text(
                  formatearFechaLarga(widget.controlador.hoy),
                  style: estilo,
                ),
                CampoCantidad(
                  etiqueta: 'Bolívares por 1 dólar',
                  controller: _valor,
                  focusNode: _foco,
                  decimales: decimalesDinero,
                  sufijo: 'Bs',
                  autofocus: true,
                  obligatorio: () => true,
                  onSubmitted: () => unawaited(_guardar()),
                ),
                if (_enCero)
                  Text(
                    'Tiene que ser mayor que 0',
                    style: estilo?.copyWith(color: colores.error),
                  )
                else if (_avisado != null && _aviso != null)
                  Text(_aviso!, style: estilo?.copyWith(color: colores.error))
                else if (anterior != null)
                  Text(
                    'Última: ${formatearBolivares(anterior.bolivaresPorDolar)}'
                    ' · ${formatearFechaLarga(anterior.fecha)}'
                    ' · ${anterior.origen.etiqueta}',
                    style: estilo,
                  ),
                BotonesCrear(
                  guardando: _guardando,
                  etiqueta: 'Guardar tasa',
                  onCrear: () => unawaited(_guardar()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
