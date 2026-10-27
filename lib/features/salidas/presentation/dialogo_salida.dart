import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/entradas/presentation/producto_elegido.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/domain/medida_venta.dart';
import 'package:inventario/features/salidas/domain/modo_venta.dart';
import 'package:inventario/features/salidas/domain/resultado_salida.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/domain/vender.dart';
import 'package:inventario/features/salidas/presentation/aviso_salida.dart';
import 'package:inventario/features/salidas/presentation/buscador_producto_salida.dart';
import 'package:inventario/features/salidas/presentation/campo_cantidad_vendida.dart';
import 'package:inventario/features/salidas/presentation/opciones_marca_salida.dart';
import 'package:inventario/features/salidas/presentation/opciones_presentacion_salida.dart';
import 'package:inventario/features/salidas/presentation/seccion_cantidad_salida.dart';
import 'package:inventario/features/salidas/presentation/selector_modo_venta.dart';
import 'package:inventario/features/salidas/presentation/teclas_salida.dart';

Future<void> mostrarDialogoSalida(
  BuildContext context, {
  required ControladorSalidas salidas,
  required ControladorExistencias existencias,
  required int? Function(int dolares) aBolivares,
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoSalida(
    salidas: salidas,
    existencias: existencias,
    aBolivares: aBolivares,
  ),
);

/// One product per sale. Built for speed: the pack, the brand and the way
/// of selling come preselected and Enter in the amount registers.
class DialogoSalida extends StatefulWidget {
  const DialogoSalida({
    super.key,
    required this.salidas,
    required this.existencias,
    required this.aBolivares,
  });

  static const _ancho = 640.0;

  final ControladorSalidas salidas;
  final ControladorExistencias existencias;
  final int? Function(int dolares) aBolivares;

  @override
  State<DialogoSalida> createState() => _DialogoSalidaState();
}

class _DialogoSalidaState extends State<DialogoSalida> {
  final _formulario = GlobalKey<FormState>();
  final _busqueda = TextEditingController();
  final _cantidad = TextEditingController();
  final _nota = TextEditingController();
  final _focoBusqueda = FocusNode();
  final _focoCantidad = FocusNode();
  Producto? _producto;
  Presentacion? _presentacion;
  int? _lote;
  var _modo = ModoVenta.piezaEntera;
  var _guardando = false;

  @override
  void dispose() {
    for (final c in [_busqueda, _cantidad, _nota]) {
      c.dispose();
    }
    _focoBusqueda.dispose();
    _focoCantidad.dispose();
    super.dispose();
  }

  /// Only products counted in pieces and kilos choose how they are sold.
  ModoVenta? get _modoActual =>
      (_producto?.forma.cuentaPiezas ?? false) ? _modo : null;

  bool get _conPresentaciones => _producto?.presentaciones.isNotEmpty ?? false;

  MedidaVenta get _medida {
    final presentacion = _presentacion;
    return presentacion != null && _conPresentaciones
        ? MedidaEnPresentacion(presentacion)
        : MedidaEnUnidad(_producto!.forma.unidad);
  }

  LoteMarca? get _loteElegido {
    final producto = _producto;
    final lote = _lote;
    return producto == null || lote == null ? null : producto.lotes[lote];
  }

  // The fields only exist after the rebuild, so focus on the next frame.
  void _enfocarDespues(FocusNode foco) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) foco.requestFocus();
      });

  /// [presentacion] comes from a scanned code; else the default pack.
  void _elegirProducto(Producto producto, Presentacion? presentacion) {
    setState(() {
      _producto = producto;
      _presentacion = presentacion ?? producto.presentacionPredeterminada;
      _modo = widget.salidas.modoPara(producto.id);
      _lote = loteSugerido(producto, _modoActual);
    });
    _enfocarDespues(_focoCantidad);
  }

  void _elegirPresentacion(Presentacion presentacion) {
    setState(() => _presentacion = presentacion);
    _formulario.currentState?.validate();
    _enfocarDespues(_focoCantidad);
  }

  void _elegirLote(int lote) {
    setState(() => _lote = lote);
    _enfocarDespues(_focoCantidad);
  }

  /// Keeps the brand if it can still sell this way, else suggests another.
  void _elegirModo(ModoVenta modo) {
    final producto = _producto;
    if (producto == null || !producto.forma.cuentaPiezas) return;
    setState(() {
      _modo = modo;
      final lote = _loteElegido;
      if (lote == null || disponibleParaVender(lote, modo) <= 0) {
        _lote = loteSugerido(producto, modo);
      }
    });
    _formulario.currentState?.validate();
    _enfocarDespues(_focoCantidad);
  }

  void _cambiarProducto() {
    setState(() {
      _producto = null;
      _presentacion = null;
      _lote = null;
    });
    _busqueda.clear();
    _cantidad.clear();
    _nota.clear();
    _enfocarDespues(_focoBusqueda);
  }

  /// Null until the fields hold a complete sale.
  Salida? _leerSalida() {
    final lote = _loteElegido;
    if (_producto == null || lote == null) return null;
    final medida = _medida;
    final escrito = CampoCantidadVendida.leer(_cantidad, medida.decimales);
    if (escrito <= 0) return null;
    return Salida(
      marca: lote.marca,
      proveedor: lote.proveedor,
      modo: _modoActual,
      presentacion: switch (medida) {
        MedidaEnPresentacion(:final presentacion) => presentacion,
        MedidaEnUnidad() => null,
      },
      cantidad: medida.aBase(escrito),
      nota: _nota.text.trim(),
    );
  }

  Future<void> _registrar({required bool otra}) async {
    if (_guardando || !(_formulario.currentState?.validate() ?? false)) return;
    final producto = _producto;
    final lote = _loteElegido;
    final salida = _leerSalida();
    if (producto == null || lote == null || salida == null) return;
    final importe = importeDeSalida(
      producto,
      lote,
      salida.cantidad,
      presentacion: salida.presentacion,
    );
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final resultado = await widget.salidas.registrar(producto.id, salida);
    if (!mounted) return;
    setState(() => _guardando = false);
    switch (resultado) {
      case SalidaRegistrada(:final producto):
        mostrarSalidaRegistrada(
          mensajero,
          widget.salidas,
          producto,
          salida,
          importe: importe,
        );
        if (otra) {
          _cambiarProducto();
        } else {
          navegador.pop();
        }
      case SinExistencias():
        mensajero.showSnackBar(
          const SnackBar(
            content: Text('Ya no hay suficiente: las existencias cambiaron'),
          ),
        );
        _cambiarProducto();
      case SalidaSinProducto():
        mensajero.showSnackBar(
          const SnackBar(content: Text('Ese producto ya no existe')),
        );
        _cambiarProducto();
    }
  }

  // Ctrl+Enter also submits the field; the shortcut already handles it.
  void _enter() {
    if (HardwareKeyboard.instance.isControlPressed) return;
    unawaited(_registrar(otra: false));
  }

  /// Packs take the digits when there are any; brands then use letters.
  List<(LogicalKeyboardKey, String)> get _teclasMarca =>
      _conPresentaciones ? teclasLetra : teclasDigito;

  Map<ShortcutActivator, VoidCallback> get _atajos {
    final producto = _producto;
    return {
      if (producto != null && _conPresentaciones)
        for (final (i, presentacion) in producto.presentaciones.indexed)
          if (i < teclasDigito.length)
            SingleActivator(teclasDigito[i].$1, alt: true): () =>
                _elegirPresentacion(presentacion),
      if (producto != null)
        for (final i in Iterable<int>.generate(producto.lotes.length))
          if (i < _teclasMarca.length)
            SingleActivator(_teclasMarca[i].$1, alt: true): () =>
                _elegirLote(i),
      for (final MapEntry(key: modo, value: (tecla, _))
          in teclasModoVenta.entries)
        SingleActivator(tecla, alt: true): () => _elegirModo(modo),
      const SingleActivator(LogicalKeyboardKey.enter, control: true): () =>
          unawaited(_registrar(otra: true)),
      const SingleActivator(
        LogicalKeyboardKey.numpadEnter,
        control: true,
      ): () =>
          unawaited(_registrar(otra: true)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final tema = Theme.of(context);
    final producto = _producto;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: _atajos,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DialogoSalida._ancho),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(espaciado.xl),
            child: Form(
              key: _formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: espaciado.lg,
                children: [
                  const EncabezadoDialogo(
                    titulo: 'Registrar salida',
                    icono: Icons.upload_outlined,
                  ),
                  if (producto == null)
                    BuscadorProductoSalida(
                      productos: widget.existencias.productos,
                      controller: _busqueda,
                      focusNode: _focoBusqueda,
                      onElegir: _elegirProducto,
                    )
                  else ...[
                    ProductoElegido(
                      producto: producto,
                      onCambiar: _cambiarProducto,
                    ),
                    ..._detalle(producto),
                  ],
                  BotonesCrear(
                    etiqueta: 'Registrar salida',
                    etiquetaOtro: 'Registrar y otra',
                    guardando: _guardando,
                    onCrear: () => unawaited(_registrar(otra: false)),
                    onCrearOtro: () => unawaited(_registrar(otra: true)),
                  ),
                  Text(
                    _conPresentaciones
                        ? 'Escribe o escanea el producto · Alt+1… presentación · '
                              'Alt+Q… marca · Enter registra · Ctrl+Enter '
                              'registra y deja lista otra · Esc cierra'
                        : 'Escribe o escanea el producto · Alt+1… marca · '
                              'Alt+P pieza entera · Alt+K por kilo · Enter '
                              'registra · Ctrl+Enter registra y deja lista '
                              'otra · Esc cierra',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _detalle(Producto producto) {
    final lote = _loteElegido;
    final modo = _modoActual;
    final tema = Theme.of(context);
    return [
      if (_conPresentaciones)
        ConEtiqueta(
          etiqueta: 'Presentación',
          child: ExcludeFocus(
            child: OpcionesPresentacionSalida(
              producto: producto,
              elegida: _presentacion,
              onElegir: _elegirPresentacion,
            ),
          ),
        ),
      if (lote == null)
        Text(
          producto.lotes.isEmpty
              ? 'No hay existencias de este producto.'
              : 'Ninguna marca tiene existencias para venderse así.',
          style: tema.textTheme.bodyMedium?.copyWith(
            color: tema.colorScheme.error,
          ),
        )
      else
        ConEtiqueta(
          etiqueta: 'Marca',
          child: ExcludeFocus(
            child: OpcionesMarcaSalida(
              producto: producto,
              elegido: _lote,
              onElegir: _elegirLote,
              atajos: [for (final (_, etiqueta) in _teclasMarca) etiqueta],
            ),
          ),
        ),
      if (modo != null)
        ConEtiqueta(
          etiqueta: 'Cómo se vende',
          child: ExcludeFocus(
            child: SelectorModoVenta(elegido: modo, onElegir: _elegirModo),
          ),
        ),
      if (lote != null) ...[
        SeccionCantidadSalida(
          producto: producto,
          lote: lote,
          modo: modo,
          medida: _medida,
          controller: _cantidad,
          focusNode: _focoCantidad,
          salida: _leerSalida,
          aBolivares: widget.aBolivares,
          onEnviar: _enter,
        ),
        TextFormField(
          controller: _nota,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nota (opcional)',
            hintText: 'Cliente, despacho, observaciones…',
          ),
          onFieldSubmitted: (_) => _enter(),
        ),
      ],
    ];
  }
}
