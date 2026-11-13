import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/features/autenticacion/application/controlador_bloqueo.dart';

/// Locks the app on its own after a while with nobody touching it, so an
/// unattended counter does not stay open. Any key, click, scroll or touch
/// starts the wait again. With "Nunca" chosen it does nothing.
class BloqueoPorInactividad extends StatefulWidget {
  const BloqueoPorInactividad({
    super.key,
    required this.bloqueo,
    required this.onBloquear,
    required this.child,
  });

  final ControladorBloqueo bloqueo;
  final VoidCallback onBloquear;
  final Widget child;

  @override
  State<BloqueoPorInactividad> createState() => _BloqueoPorInactividadState();
}

class _BloqueoPorInactividadState extends State<BloqueoPorInactividad> {
  Timer? _cuenta;

  @override
  void initState() {
    super.initState();
    widget.bloqueo.addListener(_reiniciar);
    _reiniciar();
  }

  @override
  void dispose() {
    _cuenta?.cancel();
    widget.bloqueo.removeListener(_reiniciar);
    super.dispose();
  }

  void _reiniciar() {
    _cuenta?.cancel();
    final espera = widget.bloqueo.espera;
    if (espera == null) return;
    _cuenta = Timer(espera, widget.onBloquear);
  }

  @override
  Widget build(BuildContext context) => Focus(
    // Only to hear the keyboard; the focus goes on to the screen itself.
    canRequestFocus: false,
    skipTraversal: true,
    onKeyEvent: (_, _) {
      _reiniciar();
      return KeyEventResult.ignored;
    },
    child: Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _reiniciar(),
      onPointerSignal: (_) => _reiniciar(),
      onPointerHover: (_) => _reiniciar(),
      child: widget.child,
    ),
  );
}
