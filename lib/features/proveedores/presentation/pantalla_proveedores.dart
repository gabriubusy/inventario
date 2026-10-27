import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/entradas/presentation/dialogo_entrada.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/presentation/aviso_incidencia.dart';
import 'package:inventario/features/incidencias/presentation/dialogo_incidencia.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/presentation/barra_proveedores.dart';
import 'package:inventario/features/proveedores/presentation/dialogo_proveedor.dart';
import 'package:inventario/features/proveedores/presentation/ficha_proveedor.dart';
import 'package:inventario/features/proveedores/presentation/lista_proveedores.dart';

/// Suppliers: list on the left, the chosen one's card on the right.
class PantallaProveedores extends StatefulWidget {
  const PantallaProveedores({
    super.key,
    required this.controlador,
    required this.existencias,
    required this.entradas,
    required this.incidencias,
  });

  static const _anchoMaximo = 1240.0;
  static const _anchoLista = 380.0;

  final ControladorProveedores controlador;

  /// Brands and products shown in the card come from the stock.
  final ControladorExistencias existencias;
  final ControladorEntradas entradas;
  final ControladorIncidencias incidencias;

  @override
  State<PantallaProveedores> createState() => _PantallaProveedoresState();
}

class _PantallaProveedoresState extends State<PantallaProveedores> {
  final _focoBusqueda = FocusNode();

  @override
  void dispose() {
    _focoBusqueda.dispose();
    super.dispose();
  }

  void _volver() => unawaited(Navigator.of(context).maybePop());

  void _nuevo() =>
      unawaited(mostrarDialogoProveedor(context, widget.controlador));

  void _editar() {
    final proveedor = widget.controlador.elegido;
    if (proveedor == null) return;
    unawaited(
      mostrarDialogoProveedor(
        context,
        widget.controlador,
        proveedor: proveedor,
      ),
    );
  }

  /// Opens the entry with the chosen supplier's brand already picked.
  void _registrarEntrada() => unawaited(
    mostrarDialogoEntrada(
      context,
      entradas: widget.entradas,
      existencias: widget.existencias,
      proveedores: widget.controlador.nombres,
      proveedorInicial: widget.controlador.elegido?.nombre ?? '',
    ),
  );

  void _registrarIncidencia() => unawaited(
    mostrarDialogoIncidencia(
      context,
      incidencias: widget.incidencias,
      existencias: widget.existencias,
      proveedores: widget.controlador.nombres,
      proveedorInicial: widget.controlador.elegido?.nombre ?? '',
    ),
  );

  void _responder(Incidencia incidencia, RespuestaProveedor? respuesta) =>
      unawaited(
        responderIncidencia(
          ScaffoldMessenger.of(context),
          widget.incidencias,
          incidencia,
          respuesta,
        ),
      );

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    const SingleActivator(LogicalKeyboardKey.keyI, control: true):
        _registrarIncidencia,
    const SingleActivator(LogicalKeyboardKey.escape): _volver,
    const SingleActivator(LogicalKeyboardKey.keyN, control: true): _nuevo,
    const SingleActivator(LogicalKeyboardKey.keyE, control: true): _editar,
    const SingleActivator(LogicalKeyboardKey.keyK, control: true):
        _focoBusqueda.requestFocus,
    const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
        widget.controlador.moverEleccion(-1),
    const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
        widget.controlador.moverEleccion(1),
    const SingleActivator(LogicalKeyboardKey.f2): _registrarEntrada,
  };

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return AtajosDeTeclado(
      atajos: _atajos,
      child: Scaffold(
        body: Column(
          children: [
            BarraProveedores(onVolver: _volver, onNuevo: _nuevo),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: PantallaProveedores._anchoMaximo,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(espaciado.xl),
                    child: ListenableBuilder(
                      listenable: Listenable.merge([
                        widget.controlador,
                        widget.existencias,
                        widget.incidencias,
                      ]),
                      builder: (context, _) {
                        final elegido = widget.controlador.elegido;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: espaciado.xl,
                          children: [
                            SizedBox(
                              width: PantallaProveedores._anchoLista,
                              child: ListaProveedores(
                                controlador: widget.controlador,
                                focoBusqueda: _focoBusqueda,
                                abiertasDe: (p) =>
                                    widget.incidencias.abiertasDe(p.nombre),
                              ),
                            ),
                            Expanded(
                              child: elegido == null
                                  ? const SizedBox.shrink()
                                  : FichaProveedor(
                                      proveedor: elegido,
                                      suministros: widget.controlador
                                          .suministros(elegido),
                                      onEditar: _editar,
                                      onRegistrarEntrada: _registrarEntrada,
                                      incidencias: widget.incidencias.de(
                                        elegido.nombre,
                                      ),
                                      hoy: widget.incidencias.hoy,
                                      onRegistrarIncidencia:
                                          _registrarIncidencia,
                                      onResponder: _responder,
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
