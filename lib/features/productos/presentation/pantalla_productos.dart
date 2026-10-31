import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/application/controlador_ajuste_precios.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';
import 'package:inventario/features/productos/presentation/barra_productos.dart';
import 'package:inventario/features/productos/presentation/dialogo_ajuste_precios.dart';
import 'package:inventario/features/productos/presentation/dialogo_nuevo_producto.dart';
import 'package:inventario/features/productos/presentation/elegir_imagen.dart';
import 'package:inventario/features/productos/presentation/lista_productos.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/presentation/aviso_tasa.dart';
import 'package:inventario/features/tasa/presentation/dialogo_tasa.dart';

/// Products (F4): the full-width list; creating and editing open a window.
class PantallaProductos extends StatefulWidget {
  const PantallaProductos({
    super.key,
    required this.lista,
    required this.tasa,
    required this.fotos,
    this.proveedores = const [],
    this.elegirImagen = elegirImagenDelEquipo,
    this.onKardex,
    this.ajustePrecios,
  });

  static const _anchoMaximo = 1240.0;

  final ControladorListaProductos lista;
  final ControladorTasa tasa;
  final GestorFotos fotos;
  final List<String> proveedores;
  final ElegirImagen elegirImagen;

  /// F8 opens the chosen product's kardex; left out where there is none.
  final ValueChanged<Producto>? onKardex;

  /// Ctrl+Shift+A moves a price list over many products; optional in tests.
  final ControladorAjustePrecios? ajustePrecios;

  @override
  State<PantallaProductos> createState() => _PantallaProductosState();
}

class _PantallaProductosState extends State<PantallaProductos> {
  late final _busqueda = TextEditingController(text: widget.lista.busqueda);
  final _focoBusqueda = FocusNode();
  final _focoLista = FocusNode(debugLabel: 'lista de productos');

  @override
  void dispose() {
    _busqueda.dispose();
    _focoBusqueda.dispose();
    _focoLista.dispose();
    super.dispose();
  }

  static final _teclasDeLista = {
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.numpadEnter,
  };

  // Our shortcuts already used them; without this Flutter would also move the
  // focus to a button with the arrows and press it with Enter.
  KeyEventResult _absorberTeclasDeLista(FocusNode _, KeyEvent evento) =>
      _teclasDeLista.contains(evento.logicalKey)
      ? KeyEventResult.handled
      : KeyEventResult.ignored;

  void _limpiarBusqueda() {
    _busqueda.clear();
    widget.lista.buscar('');
  }

  /// Clears the search first, then goes home.
  void _escape() {
    if (_busqueda.text.isNotEmpty) {
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

  void _editar(Producto producto) => unawaited(
    mostrarDialogoEditarProducto(
      context,
      widget.lista.existencias,
      producto: producto,
      fotos: widget.fotos,
      proveedores: widget.proveedores,
      aBolivares: widget.tasa.aBolivares,
      elegirImagen: widget.elegirImagen,
      alEditar: _guardado,
    ),
  );

  void _editarElegido() {
    final elegido = widget.lista.elegido;
    if (elegido != null) _editar(elegido);
  }

  void _kardexDelElegido() {
    final elegido = widget.lista.elegido;
    if (elegido != null) widget.onKardex?.call(elegido);
  }

  void _ponerTasa() => unawaited(mostrarDialogoTasa(context, widget.tasa));

  Future<void> _ajustarPrecios() async {
    final ajuste = widget.ajustePrecios;
    if (ajuste == null) return;
    final cuantos = await mostrarDialogoAjustePrecios(
      context,
      ajuste: ajuste,
      proveedores: widget.proveedores,
    );
    if (cuantos == null || !mounted) return;
    final mensajero = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    mensajero.showSnackBar(
      SnackBar(
        content: Text(
          cuantos == 1
              ? 'Precios ajustados en 1 producto'
              : 'Precios ajustados en $cuantos productos',
        ),
        persist: false,
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => unawaited(_deshacerAjuste(ajuste)),
        ),
      ),
    );
  }

  Future<void> _deshacerAjuste(ControladorAjustePrecios ajuste) async {
    if (await ajuste.deshacer() || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo deshacer: algún producto cambió después'),
      ),
    );
  }

  void _guardado(Producto anterior, Producto guardado) {
    final aviso = (ScaffoldMessenger.of(context)..hideCurrentSnackBar())
        .showSnackBar(
          SnackBar(
            content: Text('${guardado.nombre} guardado'),
            persist: false,
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () => unawaited(_deshacer(anterior, guardado)),
            ),
          ),
        );
    unawaited(
      aviso.closed.then((razon) async {
        // Undo decides about the photo itself, once it knows it worked.
        if (razon == SnackBarClosedReason.action) return;
        await _soltarFoto(anterior, guardado, deshecho: false);
      }),
    );
  }

  Future<void> _soltarFoto(
    Producto anterior,
    Producto guardado, {
    required bool deshecho,
  }) => widget.fotos.soltarSustituida(
    anterior: anterior.imagenId,
    actual: guardado.imagenId,
    deshecho: deshecho,
  );

  /// Refused when the product changed after the save (a sale, an entry),
  /// so that change is not lost.
  Future<void> _deshacer(Producto anterior, Producto guardado) async {
    final existencias = widget.lista.existencias;
    final actual = existencias.productos
        .where((p) => p.id == guardado.id)
        .firstOrNull;
    final resultado = actual != guardado
        ? null
        : await existencias.actualizarProducto(
            anterior.id,
            DatosProducto.desde(anterior),
          );
    final deshecho = resultado is ProductoGuardado;
    await _soltarFoto(anterior, guardado, deshecho: deshecho);
    if (deshecho || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resultado is NombreRepetido
              ? 'No se pudo deshacer: ya hay otro producto con ese nombre'
              : 'No se pudo deshacer: el producto cambió después',
        ),
      ),
    );
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    const SingleActivator(LogicalKeyboardKey.escape): _escape,
    const SingleActivator(LogicalKeyboardKey.keyN, control: true): _nuevo,
    const SingleActivator(LogicalKeyboardKey.keyK, control: true):
        _focoBusqueda.requestFocus,
    const SingleActivator(LogicalKeyboardKey.keyT, control: true): _ponerTasa,
    const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
        widget.lista.moverEleccion(-1),
    const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
        widget.lista.moverEleccion(1),
    const SingleActivator(LogicalKeyboardKey.enter): _editarElegido,
    const SingleActivator(LogicalKeyboardKey.f8): _kardexDelElegido,
    if (widget.ajustePrecios != null)
      const SingleActivator(
        LogicalKeyboardKey.keyA,
        control: true,
        shift: true,
      ): () =>
          unawaited(_ajustarPrecios()),
  };

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final lista = widget.lista;
    final tasa = widget.tasa;
    return AtajosDeTeclado(
      atajos: _atajos,
      child: Scaffold(
        body: ListenableBuilder(
          listenable: Listenable.merge([lista, lista.existencias, tasa]),
          builder: (context, _) => Column(
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
                      child: Focus(
                        focusNode: _focoLista,
                        autofocus: true,
                        onKeyEvent: _absorberTeclasDeLista,
                        child: ListaProductos(
                          controlador: lista,
                          fotos: widget.fotos,
                          busqueda: _busqueda,
                          focoBusqueda: _focoBusqueda,
                          aBolivares: tasa.aBolivares,
                          onCrear: _nuevo,
                          onAbrir: _editar,
                          onLimpiar: _limpiarBusqueda,
                          onAjustarPrecios: widget.ajustePrecios == null
                              ? null
                              : () => unawaited(_ajustarPrecios()),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
