import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/domain/filtrar_incidencias.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/resumen_incidencias.dart';
import 'package:inventario/features/incidencias/presentation/aviso_incidencia.dart';
import 'package:inventario/features/incidencias/presentation/barra_incidencias.dart';
import 'package:inventario/features/incidencias/presentation/barra_respuesta.dart';
import 'package:inventario/features/incidencias/presentation/dialogo_incidencia.dart';
import 'package:inventario/features/incidencias/presentation/filtros_incidencias.dart';
import 'package:inventario/features/incidencias/presentation/tabla_incidencias.dart';
import 'package:inventario/features/incidencias/presentation/tarjetas_resumen.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';

const _teclasRespuesta = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
];

/// Incidents of every supplier, to chase up the open ones (F6).
class PantallaIncidencias extends StatefulWidget {
  const PantallaIncidencias({
    super.key,
    required this.incidencias,
    required this.existencias,
    this.proveedores = const [],
  });

  static const _anchoMaximo = 1240.0;

  final ControladorIncidencias incidencias;
  final ControladorExistencias existencias;
  final List<String> proveedores;

  @override
  State<PantallaIncidencias> createState() => _PantallaIncidenciasState();
}

class _PantallaIncidenciasState extends State<PantallaIncidencias> {
  final _busqueda = TextEditingController();
  final _focoBusqueda = FocusNode();
  var _soloAbiertas = true;
  String? _elegidaId;

  @override
  void initState() {
    super.initState();
    _busqueda.addListener(_alBuscar);
  }

  @override
  void dispose() {
    _busqueda.dispose();
    _focoBusqueda.dispose();
    super.dispose();
  }

  void _alBuscar() => setState(() {});

  List<Incidencia> get _visibles => filtrarIncidencias(
    widget.incidencias.todas,
    texto: _busqueda.text,
    soloAbiertas: _soloAbiertas,
  );

  /// The chosen incident, or the first visible one.
  Incidencia? get _elegida {
    final visibles = _visibles;
    if (visibles.isEmpty) return null;
    return visibles.firstWhere(
      (i) => i.id == _elegidaId,
      orElse: () => visibles.first,
    );
  }

  void _volver() {
    if (_busqueda.text.isNotEmpty) {
      _busqueda.clear();
      return;
    }
    unawaited(Navigator.of(context).maybePop());
  }

  void _nueva() => unawaited(
    mostrarDialogoIncidencia(
      context,
      incidencias: widget.incidencias,
      existencias: widget.existencias,
      proveedores: widget.proveedores,
    ),
  );

  void _mover(int pasos) {
    final visibles = _visibles;
    final actual = _elegida;
    if (actual == null) return;
    final destino = (visibles.indexOf(actual) + pasos).clamp(
      0,
      visibles.length - 1,
    );
    setState(() => _elegidaId = visibles[destino].id);
  }

  void _responder(RespuestaProveedor? respuesta) {
    final elegida = _elegida;
    if (elegida == null) return;
    // Under "Abiertas" the answered row goes away, so the next one is chosen.
    final visibles = _visibles;
    final siguiente = visibles.length > 1
        ? visibles[(visibles.indexOf(elegida) + 1) % visibles.length].id
        : null;
    if (_soloAbiertas && respuesta != null) _elegidaId = siguiente;
    unawaited(
      responderIncidencia(
        ScaffoldMessenger.of(context),
        widget.incidencias,
        elegida,
        respuesta,
      ),
    );
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    const SingleActivator(LogicalKeyboardKey.escape): _volver,
    const SingleActivator(LogicalKeyboardKey.keyN, control: true): _nueva,
    const SingleActivator(LogicalKeyboardKey.keyI, control: true): _nueva,
    const SingleActivator(LogicalKeyboardKey.keyK, control: true):
        _focoBusqueda.requestFocus,
    const SingleActivator(LogicalKeyboardKey.arrowUp): () => _mover(-1),
    const SingleActivator(LogicalKeyboardKey.arrowDown): () => _mover(1),
    const SingleActivator(LogicalKeyboardKey.keyA, alt: true): () =>
        setState(() => _soloAbiertas = true),
    const SingleActivator(LogicalKeyboardKey.keyT, alt: true): () =>
        setState(() => _soloAbiertas = false),
    for (final (i, tecla) in _teclasRespuesta.indexed)
      SingleActivator(tecla, alt: true): () {
        if (_elegida?.abierta ?? false) {
          _responder(RespuestaProveedor.values[i]);
        }
      },
  };

  @override
  Widget build(BuildContext context) {
    return AtajosDeTeclado(
      atajos: _atajos,
      child: Scaffold(
        body: Column(
          children: [
            BarraIncidencias(onVolver: _volver, onNueva: _nueva),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.incidencias,
                builder: (context, _) => _Contenido(
                  hoy: widget.incidencias.hoy,
                  todas: widget.incidencias.todas,
                  visibles: _visibles,
                  elegida: _elegida,
                  filtros: FiltrosIncidencias(
                    busqueda: _busqueda,
                    focoBusqueda: _focoBusqueda,
                    soloAbiertas: _soloAbiertas,
                    abiertas: widget.incidencias.todas
                        .where((i) => i.abierta)
                        .length,
                    onSoloAbiertas: (valor) =>
                        setState(() => _soloAbiertas = valor),
                  ),
                  onElegir: (i) => setState(() => _elegidaId = i.id),
                  onResponder: _responder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.hoy,
    required this.todas,
    required this.visibles,
    required this.elegida,
    required this.filtros,
    required this.onElegir,
    required this.onResponder,
  });

  final DateTime hoy;
  final List<Incidencia> todas;
  final List<Incidencia> visibles;
  final Incidencia? elegida;
  final Widget filtros;
  final ValueChanged<Incidencia> onElegir;
  final ValueChanged<RespuestaProveedor?> onResponder;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final suave = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    final elegida = this.elegida;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: PantallaIncidencias._anchoMaximo,
        ),
        child: ListView(
          padding: EdgeInsets.all(espaciado.xl),
          children: [
            TarjetasResumen(resumen: ResumenIncidencias.de(todas, hoy)),
            SizedBox(height: espaciado.xl),
            filtros,
            SizedBox(height: espaciado.lg),
            Card(
              child: Padding(
                padding: EdgeInsets.only(top: espaciado.md),
                child: visibles.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(espaciado.xl),
                        child: Text(
                          'No hay incidencias que mostrar',
                          textAlign: TextAlign.center,
                          style: suave,
                        ),
                      )
                    : TablaIncidencias(
                        incidencias: visibles,
                        hoy: hoy,
                        elegidaId: elegida?.id,
                        onElegir: onElegir,
                      ),
              ),
            ),
            if (elegida != null) ...[
              SizedBox(height: espaciado.lg),
              BarraRespuesta(
                incidencia: elegida,
                onResponder: onResponder,
                conAtajos: true,
              ),
            ],
            SizedBox(height: espaciado.md),
            Text(
              '↑ ↓ elegir · Alt+1–4 cómo respondió · En rojo, abiertas hace '
              'más de ${Incidencia.diasParaReclamar} días: toca reclamarlas',
              style: suave,
            ),
          ],
        ),
      ),
    );
  }
}
