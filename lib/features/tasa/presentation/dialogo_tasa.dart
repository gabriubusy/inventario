import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/fechas.dart';
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
  var _guardando = false;
  var _enCero = false;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando || !(_formulario.currentState?.validate() ?? false)) return;
    final valor = CampoCantidad.leer(_valor, decimalesDinero);
    if (valor <= 0) {
      setState(() => _enCero = true);
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
                else if (anterior != null)
                  Text(
                    'Última: ${formatearBolivares(anterior.bolivaresPorDolar)}'
                    ' · ${formatearFechaLarga(anterior.fecha)}',
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
