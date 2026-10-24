import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/application/estado_sesion.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/presentation/aviso_error.dart';
import 'package:inventario/features/autenticacion/presentation/indicador_pin.dart';
import 'package:inventario/features/autenticacion/presentation/teclado_pin.dart';

final _digitosPorTecla = <LogicalKeyboardKey, String>{
  LogicalKeyboardKey.digit0: '0',
  LogicalKeyboardKey.digit1: '1',
  LogicalKeyboardKey.digit2: '2',
  LogicalKeyboardKey.digit3: '3',
  LogicalKeyboardKey.digit4: '4',
  LogicalKeyboardKey.digit5: '5',
  LogicalKeyboardKey.digit6: '6',
  LogicalKeyboardKey.digit7: '7',
  LogicalKeyboardKey.digit8: '8',
  LogicalKeyboardKey.digit9: '9',
  LogicalKeyboardKey.numpad0: '0',
  LogicalKeyboardKey.numpad1: '1',
  LogicalKeyboardKey.numpad2: '2',
  LogicalKeyboardKey.numpad3: '3',
  LogicalKeyboardKey.numpad4: '4',
  LogicalKeyboardKey.numpad5: '5',
  LogicalKeyboardKey.numpad6: '6',
  LogicalKeyboardKey.numpad7: '7',
  LogicalKeyboardKey.numpad8: '8',
  LogicalKeyboardKey.numpad9: '9',
};

/// PIN pad that also accepts digits, Backspace and Enter from the keyboard.
class EntradaPin extends StatefulWidget {
  const EntradaPin({super.key, required this.controlador});

  final ControladorSesion controlador;

  @override
  State<EntradaPin> createState() => _EntradaPinState();
}

class _EntradaPinState extends State<EntradaPin> {
  var _digitos = '';

  bool get _cargando => widget.controlador.estado is IniciandoSesion;

  void _anadir(String digito) {
    if (_cargando || _digitos.length >= Pin.longitud) return;
    setState(() => _digitos += digito);
  }

  void _borrar() {
    if (_cargando || _digitos.isEmpty) return;
    setState(() => _digitos = _digitos.substring(0, _digitos.length - 1));
  }

  Future<void> _enviar() async {
    final pin = Pin.tryParse(_digitos);
    if (pin == null) return;
    await widget.controlador.iniciarSesion(pin: pin);
    if (!mounted) return;
    setState(() => _digitos = '');
  }

  KeyEventResult _alPulsarTecla(FocusNode _, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final tecla = evento.logicalKey;
    final digito = _digitosPorTecla[tecla];
    if (digito != null) {
      _anadir(digito);
    } else if (tecla == LogicalKeyboardKey.backspace) {
      _borrar();
    } else if (tecla == LogicalKeyboardKey.enter ||
        tecla == LogicalKeyboardKey.numpadEnter) {
      unawaited(_enviar());
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return Focus(
      autofocus: true,
      onKeyEvent: _alPulsarTecla,
      child: ListenableBuilder(
        listenable: widget.controlador,
        builder: (context, _) {
          final estado = widget.controlador.estado;
          // The error hides as soon as a new attempt starts.
          final fallo =
              estado is SesionCerrada &&
              estado.pinIncorrecto &&
              _digitos.isEmpty;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IndicadorPin(introducidos: _digitos.length),
              if (fallo) ...[
                SizedBox(height: espaciado.lg),
                const AvisoError('PIN incorrecto'),
              ],
              SizedBox(height: espaciado.xl),
              // Keeps focus here so the physical keyboard keeps working after a tap.
              ExcludeFocus(
                child: TecladoPin(
                  cargando: _cargando,
                  puedeEntrar: _digitos.length == Pin.longitud,
                  onDigito: _anadir,
                  onBorrar: _borrar,
                  onEntrar: () => unawaited(_enviar()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
