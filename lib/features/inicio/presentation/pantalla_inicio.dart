import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/entradas/presentation/aviso_entrada.dart';
import 'package:inventario/features/entradas/presentation/dialogo_entrada.dart';
import 'package:inventario/features/inicio/presentation/accion_rapida.dart';
import 'package:inventario/features/inicio/presentation/acciones_rapidas.dart';
import 'package:inventario/features/inicio/presentation/barra_superior.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/presentation/cabecera_existencias.dart';
import 'package:inventario/features/productos/presentation/dialogo_nuevo_producto.dart';
import 'package:inventario/features/productos/presentation/grilla_productos.dart';
import 'package:inventario/features/productos/presentation/pantalla_productos.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/presentation/pantalla_proveedores.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';

/// Counter home: quick actions on top, live stock below.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({
    super.key,
    required this.controlador,
    required this.proveedores,
    required this.entradas,
    required this.listaProductos,
    required this.tasa,
    required this.fotos,
    required this.onBloquear,
  });

  static const _anchoMaximo = 1180.0;

  final ControladorExistencias controlador;
  final ControladorProveedores proveedores;
  final ControladorEntradas entradas;
  final ControladorListaProductos listaProductos;
  final ControladorTasa tasa;
  final GestorFotos fotos;
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

  void _ejecutar(AccionRapida accion) {
    switch (accion) {
      case AccionRapida.entrada:
        _registrarEntrada();
      case AccionRapida.productos:
        _abrirProductos();
      // Not built yet; say so instead of failing silently.
      case AccionRapida.salida || AccionRapida.merma:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('Próximamente: ${accion.titulo}')),
          );
    }
  }

  void _registrarEntrada() => unawaited(
    mostrarDialogoEntrada(
      context,
      entradas: widget.entradas,
      existencias: widget.controlador,
      proveedores: widget.proveedores.nombres,
    ),
  );

  void _deshacerEntrada() {
    if (!widget.entradas.puedeDeshacer) return;
    unawaited(deshacerEntrada(ScaffoldMessenger.of(context), widget.entradas));
  }

  void _nuevoProducto() => unawaited(
    mostrarDialogoNuevoProducto(
      context,
      widget.controlador,
      fotos: widget.fotos,
      proveedores: widget.proveedores.nombres,
      aBolivares: widget.tasa.aBolivares,
    ),
  );

  void _abrirProductos() => unawaited(
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaProductos(
          lista: widget.listaProductos,
          tasa: widget.tasa,
          fotos: widget.fotos,
          proveedores: widget.proveedores.nombres,
        ),
      ),
    ),
  );

  void _abrirProveedores() => unawaited(
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaProveedores(
          controlador: widget.proveedores,
          existencias: widget.controlador,
          entradas: widget.entradas,
        ),
      ),
    ),
  );

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    for (final accion in AccionRapida.values)
      SingleActivator(accion.tecla): () => _ejecutar(accion),
    const SingleActivator(LogicalKeyboardKey.keyK, control: true):
        _focoBusqueda.requestFocus,
    const SingleActivator(LogicalKeyboardKey.keyN, control: true):
        _nuevoProducto,
    const SingleActivator(LogicalKeyboardKey.keyL, control: true):
        widget.onBloquear,
    const SingleActivator(LogicalKeyboardKey.f5): _abrirProveedores,
    const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
        _deshacerEntrada,
  };

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return AtajosDeTeclado(
      atajos: _atajos,
      child: Scaffold(
        body: Column(
          children: [
            BarraSuperior(
              onProveedores: _abrirProveedores,
              onBloquear: widget.onBloquear,
            ),
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
                                  onNuevoProducto: _nuevoProducto,
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
    );
  }
}
