import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';
import 'package:inventario/features/productos/presentation/campo_cantidad.dart';
import 'package:inventario/features/productos/presentation/campos_producto.dart';
import 'package:inventario/features/productos/presentation/elegir_imagen.dart';
import 'package:inventario/features/productos/presentation/fila_minimo.dart';
import 'package:inventario/features/productos/presentation/foto_editable.dart';
import 'package:inventario/features/productos/presentation/lote_editable.dart';
import 'package:inventario/features/productos/presentation/seccion_lotes.dart';
import 'package:inventario/features/productos/presentation/selector_forma_conteo.dart';

const _teclasNumero = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
];

/// After a save; [otro] is true when Ctrl+Enter keeps the form for another.
typedef AlGuardarProducto = void Function(
  Producto guardado, {
  required bool otro,
});

/// The product form, shared by the new-product window and the edit panel.
class FormularioProducto extends StatefulWidget {
  const FormularioProducto({
    super.key,
    required this.controlador,
    required this.fotos,
    required this.alGuardar,
    this.producto,
    this.nombreInicial = '',
    this.proveedores = const [],
    this.aBolivares,
    this.elegirImagen = elegirImagenDelEquipo,
    this.focoNombre,
  });

  final ControladorExistencias controlador;
  final GestorFotos fotos;
  final AlGuardarProducto alGuardar;

  /// Null to create a new product.
  final Producto? producto;

  /// Prefills the name when creating, e.g. from a search with no results.
  final String nombreInicial;

  /// Saved supplier names, suggested in each brand row.
  final List<String> proveedores;

  /// Shows each price in bolívares; null hides it.
  final int? Function(int dolares)? aBolivares;

  final ElegirImagen elegirImagen;

  /// Lets the edit panel's screen jump to the name with Enter.
  final FocusNode? focoNombre;

  @override
  State<FormularioProducto> createState() => _FormularioProductoState();
}

class _FormularioProductoState extends State<FormularioProducto> {
  final _formulario = GlobalKey<FormState>();
  final _campoNombre = GlobalKey<FormFieldState<String>>();
  late final _nombre = TextEditingController(
    text: widget.producto?.nombre ?? widget.nombreInicial,
  );
  late final _minimo = TextEditingController(text: _minimoInicial());
  late final _foto = FotoEditable(
    widget.fotos,
    widget.elegirImagen,
    inicial: widget.producto?.imagenId,
  );
  late final List<LoteEditable> _lotes = _lotesIniciales();
  late var _categoria = widget.producto?.categoria ?? Categoria.carnes;
  late var _forma = widget.producto?.forma ?? FormaConteo.porKilo;
  FocusNode? _focoPropio;
  var _guardando = false;
  var _repetido = false;

  bool get _editando => widget.producto != null;

  /// Pieces for litres would leave the saved quantities meaningless.
  bool get _formaEditable => !(widget.producto?.tieneExistencias ?? false);

  FocusNode get _focoNombre =>
      widget.focoNombre ?? (_focoPropio ??= FocusNode());

  int get _decimalesMinimo => _forma.cuentaPiezas ? 0 : _forma.unidad.decimales;

  String _minimoInicial() {
    final producto = widget.producto;
    if (producto == null) return '';
    final forma = producto.forma;
    return formatDecimal(
      producto.minimo,
      decimales: forma.cuentaPiezas ? 0 : forma.unidad.decimales,
    );
  }

  List<LoteEditable> _lotesIniciales() {
    final producto = widget.producto;
    if (producto == null || producto.lotes.isEmpty) return [LoteEditable()];
    return [
      for (final lote in producto.lotes)
        LoteEditable.desde(lote, producto.forma),
    ];
  }

  @override
  void dispose() {
    _nombre.dispose();
    _minimo.dispose();
    _foto.dispose();
    _focoPropio?.dispose();
    for (final lote in _lotes) {
      lote.dispose();
    }
    super.dispose();
  }

  bool _esRepetido(LoteEditable lote) => _lotes
      .take(_lotes.indexOf(lote))
      .any((otro) => !otro.vacio && otro.clave == lote.clave);

  // Removed rows are still on screen this frame; dispose them afterwards.
  void _desecharDespues(List<LoteEditable> lotes) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final lote in lotes) {
          lote.dispose();
        }
      });

  void _agregarLote() {
    final lote = LoteEditable();
    setState(() => _lotes.add(lote));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) lote.focoMarca.requestFocus();
    });
  }

  void _quitarLote(LoteEditable lote) {
    setState(() => _lotes.remove(lote));
    _desecharDespues([lote]);
  }

  String? _validarNombre(String? texto) {
    if (texto == null || texto.trim().isEmpty) return 'Escribe el nombre';
    if (_repetido) return 'Ya existe un producto con ese nombre';
    return null;
  }

  void _nombreCambiado(String _) {
    setState(() {}); // The photo shows the name's initial.
    if (!_repetido) return;
    _repetido = false;
    _campoNombre.currentState?.validate();
  }

  /// Category and way of counting stay: the next product is usually similar.
  void _prepararOtro() {
    final sobrantes = _lotes.sublist(1);
    setState(() => _lotes.removeRange(1, _lotes.length));
    _desecharDespues(sobrantes);
    _lotes.first.limpiar();
    _foto.quitar();
    _formulario.currentState?.reset();
    _focoNombre.requestFocus();
  }

  DatosProducto _leer() => DatosProducto(
    nombre: _nombre.text.trim(),
    categoria: _categoria,
    forma: _forma,
    minimo: CampoCantidad.leer(_minimo, _decimalesMinimo),
    imagenId: _foto.id,
    lotes: [
      for (final lote in _lotes)
        if (!lote.vacio) lote.leer(_forma),
    ],
  );

  Future<void> _guardar({required bool otro}) async {
    if (_guardando || _foto.cargando) return;
    if (!(_formulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final producto = widget.producto;
    final resultado = producto == null
        ? await widget.controlador.crearProducto(_leer())
        : await widget.controlador.actualizarProducto(producto.id, _leer());
    if (!mounted) return;
    setState(() => _guardando = false);
    switch (resultado) {
      case ProductoGuardado(producto: final guardado):
        _foto.confirmar();
        final seguir = otro && !_editando;
        if (seguir) _prepararOtro();
        widget.alGuardar(guardado, otro: seguir);
      case NombreRepetido():
        _repetido = true;
        _campoNombre.currentState?.validate();
        _focoNombre.requestFocus();
    }
  }

  // Ctrl+Enter also submits the field; the shortcut already handles it.
  void _enterEnMinimo() {
    if (HardwareKeyboard.instance.isControlPressed) return;
    unawaited(_guardar(otro: false));
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    for (final (i, categoria) in Categoria.values.indexed)
      if (i < _teclasNumero.length)
        SingleActivator(_teclasNumero[i], alt: true): () =>
            setState(() => _categoria = categoria),
    if (_formaEditable)
      for (final (i, forma) in FormaConteo.values.indexed)
        if (i < teclasFormaConteo.length)
          SingleActivator(teclasFormaConteo[i].$1, alt: true): () =>
              setState(() => _forma = forma),
    const SingleActivator(LogicalKeyboardKey.keyM, control: true): _agregarLote,
    const SingleActivator(LogicalKeyboardKey.keyF, alt: true): () =>
        unawaited(_foto.elegir()),
    const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
        unawaited(_guardar(otro: false)),
    if (!_editando) ...{
      const SingleActivator(LogicalKeyboardKey.enter, control: true): () =>
          unawaited(_guardar(otro: true)),
      const SingleActivator(
        LogicalKeyboardKey.numpadEnter,
        control: true,
      ): () =>
          unawaited(_guardar(otro: true)),
    },
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return AtajosDeTeclado(
      atajos: _atajos,
      child: Form(
        key: _formulario,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: context.espaciado.lg,
          children: [
            CamposProducto(
              foto: _foto,
              fotos: widget.fotos,
              campoNombre: _campoNombre,
              nombre: _nombre,
              focoNombre: _focoNombre,
              autofocus: !_editando,
              validarNombre: _validarNombre,
              onNombreCambiado: _nombreCambiado,
              categoria: _categoria,
              onCategoria: (c) => setState(() => _categoria = c),
              forma: _forma,
              formaEditable: _formaEditable,
              onForma: (f) => setState(() => _forma = f),
            ),
            SeccionLotes(
              lotes: _lotes,
              forma: _forma,
              proveedores: widget.proveedores,
              editando: _editando,
              aBolivares: widget.aBolivares,
              esRepetido: _esRepetido,
              onAgregar: _agregarLote,
              onQuitar: _quitarLote,
            ),
            FilaMinimo(
              controller: _minimo,
              forma: _forma,
              decimales: _decimalesMinimo,
              onSubmitted: _enterEnMinimo,
            ),
            BotonesCrear(
              guardando: _guardando,
              etiqueta: _editando ? 'Guardar' : 'Crear',
              atajo: _editando ? 'Ctrl+S' : 'Enter',
              onCrear: () => unawaited(_guardar(otro: false)),
              onCrearOtro: _editando
                  ? null
                  : () => unawaited(_guardar(otro: true)),
            ),
            Text(
              _editando
                  ? 'Alt+1–4 categoría · Alt+F foto · Ctrl+M otra marca · '
                        'Ctrl+S guarda'
                  : 'Alt+1–4 categoría · Alt+Q W E R cómo se cuenta · '
                        'Alt+F foto · Ctrl+M otra marca · Esc cierra',
              textAlign: TextAlign.center,
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
