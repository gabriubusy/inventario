import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/presentation/dialogo_tasa.dart';

/// Opens the rate window once a day while today's rate is missing (no
/// internet, service down). Esc closes it; F1 asks again before selling.
/// The app is left open for days, so the date is watched too: once it
/// changes, the saved rate is yesterday's and has to be asked for again.
class PedirTasaSiFalta extends StatefulWidget {
  const PedirTasaSiFalta({
    super.key,
    required this.tasa,
    required this.child,
    this.cada = const Duration(minutes: 1),
  });

  final ControladorTasa tasa;

  /// How often the date is looked at; shorter in tests.
  final Duration cada;

  final Widget child;

  @override
  State<PedirTasaSiFalta> createState() => _PedirTasaSiFaltaState();
}

class _PedirTasaSiFaltaState extends State<PedirTasaSiFalta> {
  DateTime? _pedidaEl;
  Timer? _reloj;

  @override
  void initState() {
    super.initState();
    widget.tasa.addListener(_revisar);
    _reloj = Timer.periodic(
      widget.cada,
      (_) => unawaited(widget.tasa.revisarDia()),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _revisar());
  }

  @override
  void dispose() {
    _reloj?.cancel();
    widget.tasa.removeListener(_revisar);
    super.dispose();
  }

  void _revisar() {
    if (!mounted || !widget.tasa.hayQuePedirla) return;
    final pedida = _pedidaEl;
    final hoy = widget.tasa.hoy;
    if (pedida != null && diasEntre(pedida, hoy) == 0) return;
    _pedidaEl = hoy;
    unawaited(mostrarDialogoTasa(context, widget.tasa));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
