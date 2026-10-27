import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/resultado_cambio_pin.dart';
import 'package:inventario/features/autenticacion/presentation/aviso_error.dart';
import 'package:inventario/features/autenticacion/presentation/indicador_pin.dart';
import 'package:inventario/features/autenticacion/presentation/pasos_cambio_pin.dart';
import 'package:inventario/features/autenticacion/presentation/teclado_pin.dart';
import 'package:inventario/features/autenticacion/presentation/teclas_pin.dart';

Future<void> mostrarDialogoCambiarPin(
  BuildContext context,
  ControladorSesion controlador,
) => showDialog<void>(
  context: context,
  builder: (_) => DialogoCambiarPin(controlador: controlador),
);

/// Current PIN, new PIN, new PIN again; the first two move on by themselves
/// at the fourth digit and the last one is confirmed with Enter.
class DialogoCambiarPin extends StatefulWidget {
  const DialogoCambiarPin({super.key, required this.controlador});

  static const _ancho = 380.0;

  final ControladorSesion controlador;

  @override
  State<DialogoCambiarPin> createState() => _DialogoCambiarPinState();
}

class _DialogoCambiarPinState extends State<DialogoCambiarPin> {
  var _paso = PasoCambioPin.actual;
  var _digitos = '';
  Pin? _actual;
  Pin? _nuevo;
  String? _error;
  var _guardando = false;

  void _anadir(String digito) {
    if (_guardando || _digitos.length >= Pin.longitud) return;
    setState(() {
      _digitos += digito;
      _error = null;
    });
    if (_digitos.length == Pin.longitud && _paso != PasoCambioPin.repetir) {
      _siguiente();
    }
  }

  void _borrar() {
    if (_guardando || _digitos.isEmpty) return;
    setState(() => _digitos = _digitos.substring(0, _digitos.length - 1));
  }

  void _siguiente() {
    final pin = Pin.tryParse(_digitos);
    if (pin == null) return;
    switch (_paso) {
      case PasoCambioPin.actual:
        setState(() {
          _actual = pin;
          _paso = PasoCambioPin.nuevo;
          _digitos = '';
        });
      case PasoCambioPin.nuevo:
        setState(() {
          _nuevo = pin;
          _paso = PasoCambioPin.repetir;
          _digitos = '';
        });
      case PasoCambioPin.repetir:
        if (pin != _nuevo) {
          setState(() {
            _digitos = '';
            _error = 'No coincide con el nuevo PIN. Escríbelo otra vez.';
          });
          return;
        }
        unawaited(_guardar());
    }
  }

  Future<void> _guardar() async {
    final actual = _actual;
    final nuevo = _nuevo;
    if (actual == null || nuevo == null) return;
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final resultado = await widget.controlador.cambiarPin(
      actual: actual,
      nuevo: nuevo,
    );
    if (!mounted) return;
    switch (resultado) {
      case PinCambiado():
        navegador.pop();
        mensajero
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('PIN cambiado')));
      case PinActualIncorrecto():
        setState(() {
          _guardando = false;
          _paso = PasoCambioPin.actual;
          _digitos = '';
          _actual = null;
          _nuevo = null;
          _error = 'El PIN actual no es correcto.';
        });
    }
  }

  KeyEventResult _alPulsarTecla(FocusNode _, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final tecla = evento.logicalKey;
    final digito = digitoDeTecla(tecla);
    if (digito != null) {
      _anadir(digito);
    } else if (tecla == LogicalKeyboardKey.backspace) {
      _borrar();
    } else if (tecla == LogicalKeyboardKey.enter ||
        tecla == LogicalKeyboardKey.numpadEnter) {
      _siguiente();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final error = _error;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: DialogoCambiarPin._ancho),
        child: Focus(
          autofocus: true,
          onKeyEvent: _alPulsarTecla,
          child: Padding(
            padding: EdgeInsets.all(espaciado.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: espaciado.lg,
              children: [
                const EncabezadoDialogo(
                  titulo: 'Cambiar PIN',
                  icono: Icons.password,
                ),
                PasosCambioPin(actual: _paso),
                Text(
                  _paso.titulo,
                  textAlign: TextAlign.center,
                  style: tema.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IndicadorPin(introducidos: _digitos.length),
                if (error != null) AvisoError(error),
                // Keeps the focus up here so the keyboard keeps working.
                ExcludeFocus(
                  child: TecladoPin(
                    cargando: _guardando,
                    puedeEntrar: _digitos.length == Pin.longitud,
                    etiquetaEntrar: _paso == PasoCambioPin.repetir
                        ? 'Guardar'
                        : 'Siguiente',
                    onDigito: _anadir,
                    onBorrar: _borrar,
                    onEntrar: _siguiente,
                  ),
                ),
                Text(
                  'También con el teclado: números, Retroceso borra, '
                  'Enter guarda · Esc cierra',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
