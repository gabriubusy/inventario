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
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/domain/linea_ticket.dart';
import 'package:inventario/features/salidas/domain/medida_venta.dart';
import 'package:inventario/features/salidas/domain/modo_venta.dart';
import 'package:inventario/features/salidas/domain/resultado_cobro.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/domain/ticket.dart';
import 'package:inventario/features/salidas/domain/vender.dart';
import 'package:inventario/features/salidas/presentation/aviso_venta.dart';
import 'package:inventario/features/salidas/presentation/botones_mas_vendidos.dart';
import 'package:inventario/features/salidas/presentation/buscador_producto_salida.dart';
import 'package:inventario/features/salidas/presentation/campo_cantidad_vendida.dart';
import 'package:inventario/features/salidas/presentation/detalle_salida.dart';
import 'package:inventario/features/salidas/presentation/dialogo_cobro.dart';
import 'package:inventario/features/salidas/presentation/seccion_ticket.dart';
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

/// F1: a customer's ticket. Each product goes in with Enter (pack, brand and
/// way of selling preselected) and F10 charges them all together.
class DialogoSalida extends StatefulWidget {
  const DialogoSalida({
    super.key,
    required this.salidas,
    required this.existencias,
    required this.aBolivares,
  });

  static const _ancho = 760.0;

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

  /// The product as it would be after the lines already in the ticket.
  Producto? _producto;
  Presentacion? _presentacion;
  int? _lote;
  var _modo = ModoVenta.piezaEntera;
  int? _elegida;
  (int, LineaTicket)? _quitada;
  var _cobrando = false;

  /// Worked out once when the window opens, not on every rebuild.
  late final _masVendidos = widget.salidas.masVendidosAhora();

  Ticket get _ticket => widget.salidas.ticketEnCurso;

  set _ticket(Ticket ticket) => widget.salidas.ticketEnCurso = ticket;

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

  Producto? _actual(String id) =>
      widget.existencias.productos.where((p) => p.id == id).firstOrNull;

  // The fields only exist after the rebuild, so focus on the next frame.
  void _enfocarDespues(FocusNode foco) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) foco.requestFocus();
      });

  /// [presentacion] comes from a scanned code; else the default pack.
  void _elegirProducto(Producto producto, Presentacion? presentacion) {
    final restante = _ticket.aplicado(producto) ?? producto;
    setState(() {
      _producto = restante;
      _presentacion = presentacion ?? restante.presentacionPredeterminada;
      _modo = widget.salidas.modoPara(restante.id);
      _lote = loteSugerido(restante, _modoActual);
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

  /// Null until the fields hold a complete line.
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

  /// Puts the product being typed into the ticket; false if it can't.
  bool _agregar() {
    if (!(_formulario.currentState?.validate() ?? false)) return false;
    final producto = _producto;
    final lote = _loteElegido;
    final salida = _leerSalida();
    if (producto == null || lote == null || salida == null) return false;
    final linea = LineaTicket(
      productoId: producto.id,
      producto: producto.nombre,
      forma: producto.forma,
      salida: salida,
      importe: importeDeSalida(
        producto,
        lote,
        salida.cantidad,
        presentacion: salida.presentacion,
      ),
    );
    final actual = _actual(producto.id);
    final nuevo = actual == null ? null : _ticket.agregar(actual, linea);
    if (nuevo == null) {
      _avisar('Ya no hay suficiente de ${producto.nombre}');
      _cambiarProducto();
      return false;
    }
    setState(() {
      _ticket = nuevo;
      _elegida = null;
    });
    _cambiarProducto();
    return true;
  }

  void _quitar(int indice) {
    if (indice < 0 || indice >= _ticket.lineas.length) return;
    setState(() {
      _quitada = (indice, _ticket.lineas[indice]);
      _ticket = _ticket.sin(indice);
      _elegida = null;
    });
  }

  void _recuperar() {
    final quitada = _quitada;
    if (quitada == null) return;
    setState(() {
      _ticket = _ticket.con(quitada.$1, quitada.$2);
      _quitada = null;
    });
  }

  void _moverEleccion(int pasos) {
    final total = _ticket.lineas.length;
    if (total == 0) return;
    setState(
      () => _elegida = ((_elegida ?? total) + pasos).clamp(0, total - 1),
    );
  }

  /// F10: the line being typed goes in first, then the payment window.
  Future<void> _cobrar() async {
    if (_cobrando) return;
    if (_leerSalida() != null && !_agregar()) return;
    final ticket = _ticket;
    if (ticket.vacio) return;
    final tasa = widget.salidas.tasaDeHoy;
    if (tasa == null) {
      _avisar('Falta la tasa de hoy: escríbela con Ctrl+T');
      return;
    }
    _cobrando = true;
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final resultado = await mostrarDialogoCobro(
      context,
      total: ticket.total,
      tasa: tasa,
      medioInicial: widget.salidas.ultimoMedio,
      onCobrar: (pagos) => widget.salidas.cobrar(ticket, pagos),
    );
    _cobrando = false;
    if (!mounted) return;
    switch (resultado) {
      case VentaCobrada(:final venta):
        navegador.pop();
        mostrarVentaCobrada(mensajero, widget.salidas, venta);
      case CobroSinExistencias(:final linea):
        _avisar(
          'Ya no hay suficiente de ${linea.producto}: quítalo del ticket',
        );
      case CobroIncompleto() || CobroSinTasa() || null:
        _enfocarDespues(_focoBusqueda);
    }
  }

  void _avisar(String texto) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));

  // Ctrl+Enter used to register and keep the window; F10 replaces it.
  void _enter() {
    if (HardwareKeyboard.instance.isControlPressed) return;
    _agregar();
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
      const SingleActivator(LogicalKeyboardKey.f10): () => unawaited(_cobrar()),
      for (final (i, masVendido) in _masVendidos.indexed)
        SingleActivator(teclasMasVendidos[i], control: true): () =>
            _elegirProducto(masVendido, null),
      const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true): () =>
          _moverEleccion(-1),
      const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true): () =>
          _moverEleccion(1),
      const SingleActivator(LogicalKeyboardKey.delete, alt: true): () =>
          _quitar(_elegida ?? _ticket.lineas.length - 1),
      const SingleActivator(LogicalKeyboardKey.keyZ, alt: true): _recuperar,
    };
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final tema = Theme.of(context);
    final producto = _producto;
    final lote = _loteElegido;
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
                    titulo: 'Vender',
                    icono: Icons.upload_outlined,
                  ),
                  if (producto == null) ...[
                    BuscadorProductoSalida(
                      productos: widget.existencias.productos,
                      controller: _busqueda,
                      focusNode: _focoBusqueda,
                      onElegir: _elegirProducto,
                    ),
                    BotonesMasVendidos(
                      productos: _masVendidos,
                      onElegir: (producto) => _elegirProducto(producto, null),
                    ),
                  ] else ...[
                    ProductoElegido(
                      producto: producto,
                      onCambiar: _cambiarProducto,
                    ),
                    DetalleSalida(
                      producto: producto,
                      presentacion: _conPresentaciones ? _presentacion : null,
                      lote: _lote,
                      modo: _modoActual,
                      teclasMarca: [
                        for (final (_, etiqueta) in _teclasMarca) etiqueta,
                      ],
                      onPresentacion: _elegirPresentacion,
                      onLote: _elegirLote,
                      onModo: _elegirModo,
                    ),
                    if (lote != null)
                      CantidadYNota(
                        producto: producto,
                        lote: lote,
                        modo: _modoActual,
                        medida: _medida,
                        cantidad: _cantidad,
                        focoCantidad: _focoCantidad,
                        nota: _nota,
                        salida: _leerSalida,
                        aBolivares: widget.aBolivares,
                        onEnviar: _enter,
                      ),
                    BotonesCrear(
                      etiqueta: 'Agregar al ticket',
                      guardando: false,
                      onCrear: _agregar,
                    ),
                  ],
                  SeccionTicket(
                    ticket: _ticket,
                    elegida: _elegida,
                    hayQuitada: _quitada != null,
                    aBolivares: widget.aBolivares,
                    onElegir: (i) => setState(() => _elegida = i),
                    onQuitar: _quitar,
                    onRecuperar: _recuperar,
                    onCobrar: () => unawaited(_cobrar()),
                  ),
                  Text(
                    _conPresentaciones
                        ? 'Escribe o escanea el producto · Ctrl+1… más '
                              'vendidos · Alt+1… presentación · '
                              'Alt+Q… marca · Enter agrega · F10 cobra · '
                              'Alt+↑↓ elige línea · Alt+Supr la quita · Esc cierra '
                              '(el ticket se guarda)'
                        : 'Escribe o escanea el producto · Ctrl+1… más '
                              'vendidos · Alt+1… marca · '
                              'Alt+P pieza entera · Alt+K por kilo · Enter '
                              'agrega · F10 cobra · Alt+↑↓ elige línea · '
                              'Alt+Supr la quita · Esc cierra (el ticket se guarda)',
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
}
