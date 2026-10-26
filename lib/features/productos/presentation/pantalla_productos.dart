import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';
import 'package:inventario/features/productos/presentation/barra_productos.dart';
import 'package:inventario/features/productos/presentation/dialogo_nuevo_producto.dart';
import 'package:inventario/features/productos/presentation/elegir_imagen.dart';
import 'package:inventario/features/productos/presentation/lista_productos.dart';
import 'package:inventario/features/productos/presentation/panel_producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/presentation/aviso_tasa.dart';
import 'package:inventario/features/tasa/presentation/dialogo_tasa.dart';

/// Products (F4): the list on the left, the chosen one's form on the right.
class PantallaProductos extends StatefulWidget {
  const PantallaProductos({
    super.key,
    required this.lista,
    required this.tasa,
    required this.fotos,
    this.proveedores = const [],
    this.elegirImagen = elegirImagenDelEquipo,
  });

  static const _anchoMaximo = 1360.0;
  static const _anchoPanel = 460.0;

  final ControladorListaProductos lista;
  final ControladorTasa tasa;
  final GestorFotos fotos;
  final List<String> proveedores;
  final ElegirImagen elegirImagen;

  @override
  State<PantallaProductos> createState() => _PantallaProductosState();
}

class _PantallaProductosState extends State<PantallaProductos> {
  late final _busqueda = TextEditingController(text: widget.lista.busqueda);
  final _focoBusqueda = FocusNode();
  final _focoNombre = FocusNode();
  final _focoPanel = FocusNode(canRequestFocus: false, skipTraversal: true);

  @override
  void dispose() {
    _busqueda.dispose();
    _focoBusqueda.dispose();
    _focoNombre.dispose();
    _focoPanel.dispose();
    super.dispose();
  }

  void _limpiarBusqueda() {
    _busqueda.clear();
    widget.lista.buscar('');
  }

  /// Leaves the form first, then clears the search, then goes home.
  void _escape() {
    if (_focoPanel.hasFocus) {
      _focoBusqueda.requestFocus();
    } else if (_busqueda.text.isNotEmpty) {
      _limpiarBusqueda();
    } else {
      unawaited(Navigator.of(context).maybePop());
    }
  }

  void _nuevo([String nombre = '']) => unawaited(
    mostrarDialogoNuevoProducto(
      context,
      widget.lista.existencias,
      fotos: widget.fotos,
      proveedores: widget.proveedores,
      aBolivares: widget.tasa.aBolivares,
      nombreInicial: nombre,
      elegirImagen: widget.elegirImagen,
    ),
  );

  void _ponerTasa() => unawaited(mostrarDialogoTasa(context, widget.tasa));

  void _guardado(Producto anterior, Producto guardado) {
    final aviso = (ScaffoldMessenger.of(context)..hideCurrentSnackBar())
        .showSnackBar(
          SnackBar(
            content: Text('${guardado.nombre} guardado'),
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () => unawaited(_deshacer(anterior)),
            ),
          ),
        );
    unawaited(
      aviso.closed.then(
        (razon) => widget.fotos.soltarSustituida(
          anterior: anterior.imagenId,
          actual: guardado.imagenId,
          deshecho: razon == SnackBarClosedReason.action,
        ),
      ),
    );
  }

  Future<void> _deshacer(Producto anterior) async {
    final resultado = await widget.lista.existencias.actualizarProducto(
      anterior.id,
      DatosProducto.desde(anterior),
    );
    if (resultado is NombreRepetido && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo deshacer: ya hay otro producto con ese nombre',
          ),
        ),
      );
    }
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    const SingleActivator(LogicalKeyboardKey.escape): _escape,
    const SingleActivator(LogicalKeyboardKey.keyN, control: true): _nuevo,
    const SingleActivator(LogicalKeyboardKey.keyK, control: true):
        _focoBusqueda.requestFocus,
    const SingleActivator(LogicalKeyboardKey.keyT, control: true): _ponerTasa,
  };

  // Only while not typing in the form, where arrows and Enter have their use.
  Map<ShortcutActivator, VoidCallback> get _atajosLista => {
    const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
        widget.lista.moverEleccion(-1),
    const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
        widget.lista.moverEleccion(1),
    const SingleActivator(LogicalKeyboardKey.enter): _focoNombre.requestFocus,
  };

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final lista = widget.lista;
    final tasa = widget.tasa;
    return AtajosDeTeclado(
      atajos: _atajosLista,
      activo: () => !_focoPanel.hasFocus,
      child: AtajosDeTeclado(
        atajos: _atajos,
        child: Scaffold(
          body: ListenableBuilder(
            listenable: Listenable.merge([lista, lista.existencias, tasa]),
            builder: (context, _) {
              final elegido = lista.elegido;
              return Column(
                children: [
                  BarraProductos(
                    resumen: resumenProductos(lista.existencias.productos),
                    tasa: tasa,
                    onVolver: () => unawaited(Navigator.of(context).maybePop()),
                    onTasa: _ponerTasa,
                    onNuevo: _nuevo,
                  ),
                  if (!tasa.esDeHoy)
                    AvisoTasa(controlador: tasa, onPoner: _ponerTasa),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: PantallaProductos._anchoMaximo,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(espaciado.xl),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: espaciado.xl,
                            children: [
                              Expanded(
                                child: ListaProductos(
                                  controlador: lista,
                                  fotos: widget.fotos,
                                  busqueda: _busqueda,
                                  focoBusqueda: _focoBusqueda,
                                  aBolivares: tasa.aBolivares,
                                  onCrear: _nuevo,
                                  onLimpiar: _limpiarBusqueda,
                                ),
                              ),
                              SizedBox(
                                width: PantallaProductos._anchoPanel,
                                child: Focus(
                                  focusNode: _focoPanel,
                                  child: elegido == null
                                      ? const SizedBox.shrink()
                                      : PanelProducto(
                                          producto: elegido,
                                          existencias: lista.existencias,
                                          fotos: widget.fotos,
                                          focoNombre: _focoNombre,
                                          proveedores: widget.proveedores,
                                          aBolivares: tasa.aBolivares,
                                          elegirImagen: widget.elegirImagen,
                                          alGuardar: _guardado,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
