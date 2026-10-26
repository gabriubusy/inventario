import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shortcuts that work wherever the focus is, even after a click leaves it
/// on no field. Only the topmost route's shortcuts run.
class AtajosDeTeclado extends StatefulWidget {
  const AtajosDeTeclado({
    super.key,
    required this.atajos,
    required this.child,
    this.activo,
  });

  final Map<ShortcutActivator, VoidCallback> atajos;
  final Widget child;

  /// Asked on every key; when false the key goes on to the focused field.
  final bool Function()? activo;

  @override
  State<AtajosDeTeclado> createState() => _AtajosDeTecladoState();
}

class _AtajosDeTecladoState extends State<AtajosDeTeclado> {
  ModalRoute<Object?>? _ruta;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_alPulsar);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ruta = ModalRoute.of(context);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_alPulsar);
    super.dispose();
  }

  bool _alPulsar(KeyEvent evento) {
    if (evento is! KeyDownEvent) return false;
    if (!(_ruta?.isCurrent ?? true)) return false;
    if (!(widget.activo?.call() ?? true)) return false;
    for (final MapEntry(key: atajo, value: accion) in widget.atajos.entries) {
      if (atajo.accepts(evento, HardwareKeyboard.instance)) {
        accion();
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
