import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/inicio/presentation/accion_rapida.dart';
import 'package:inventario/features/inicio/presentation/acciones_rapidas.dart';
import 'package:inventario/features/inicio/presentation/barra_superior.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/presentation/cabecera_existencias.dart';
import 'package:inventario/features/productos/presentation/grilla_productos.dart';

/// Counter home: quick actions on top, live stock below.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({
    super.key,
    required this.controlador,
    required this.onBloquear,
  });

  static const _anchoMaximo = 1180.0;

  final ControladorExistencias controlador;
  final VoidCallback onBloquear;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final _focoBusqueda = FocusNode();

  @override
  void dispose() {
    _focoBusqueda.dispose();
    super.dispose();
  }

  // Registration flows are the next step; until then say so instead of failing silently.
  void _ejecutar(AccionRapida accion) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Próximamente: ${accion.titulo}')));
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    for (final accion in AccionRapida.values)
      SingleActivator(accion.tecla): () => _ejecutar(accion),
    const SingleActivator(LogicalKeyboardKey.keyK, control: true):
        _focoBusqueda.requestFocus,
    const SingleActivator(LogicalKeyboardKey.keyL, control: true):
        widget.onBloquear,
  };

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return CallbackShortcuts(
      bindings: _atajos,
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              BarraSuperior(onBloquear: widget.onBloquear),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, limites) {
                    final lateral = math.max(
                      espaciado.xl,
                      (limites.maxWidth - PantallaInicio._anchoMaximo) / 2,
                    );
                    return ListenableBuilder(
                      listenable: widget.controlador,
                      builder: (context, _) => CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              lateral,
                              espaciado.xl,
                              lateral,
                              espaciado.xl,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                spacing: espaciado.xl,
                                children: [
                                  AccionesRapidas(onAccion: _ejecutar),
                                  CabeceraExistencias(
                                    controlador: widget.controlador,
                                    focoBusqueda: _focoBusqueda,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              lateral,
                              0,
                              lateral,
                              espaciado.xl,
                            ),
                            sliver: GrillaProductos(
                              estado: widget.controlador.estado,
                              productos: widget.controlador.visibles,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
