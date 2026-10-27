import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/presentation/dialogo_tasa.dart';

/// Opens the rate window once on entering when today's rate is missing
/// (no internet, service down). Esc closes it; F1 asks again before selling.
class PedirTasaSiFalta extends StatefulWidget {
  const PedirTasaSiFalta({super.key, required this.tasa, required this.child});

  final ControladorTasa tasa;
  final Widget child;

  @override
  State<PedirTasaSiFalta> createState() => _PedirTasaSiFaltaState();
}

class _PedirTasaSiFaltaState extends State<PedirTasaSiFalta> {
  var _pedida = false;

  @override
  void initState() {
    super.initState();
    widget.tasa.addListener(_revisar);
    WidgetsBinding.instance.addPostFrameCallback((_) => _revisar());
  }

  @override
  void dispose() {
    widget.tasa.removeListener(_revisar);
    super.dispose();
  }

  void _revisar() {
    if (_pedida || !mounted || !widget.tasa.hayQuePedirla) return;
    _pedida = true;
    unawaited(mostrarDialogoTasa(context, widget.tasa));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
