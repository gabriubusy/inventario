import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/entradas/domain/entrada.dart';
import 'package:inventario/features/entradas/domain/resultado_entrada.dart';
import 'package:inventario/features/entradas/presentation/aviso_entrada.dart';
import 'package:inventario/features/entradas/presentation/buscador_producto_entrada.dart';
import 'package:inventario/features/entradas/presentation/campo_cantidad_recibida.dart';
import 'package:inventario/features/entradas/presentation/campos_entrada.dart';
import 'package:inventario/features/entradas/presentation/opciones_marca.dart';
import 'package:inventario/features/entradas/presentation/producto_elegido.dart';
import 'package:inventario/features/entradas/presentation/vista_previa_entrada.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';

const _teclasMarca = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
];

/// [proveedorInicial] preselects that supplier's brand (opened from F5).
Future<void> mostrarDialogoEntrada(
  BuildContext context, {
  required ControladorEntradas entradas,
  required ControladorExistencias existencias,
  List<String> proveedores = const [],
  String proveedorInicial = '',
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoEntrada(
    entradas: entradas,
    existencias: existencias,
    proveedores: proveedores,
    proveedorInicial: proveedorInicial,
  ),
);

/// One product per entry: pick it, pick the brand, type what arrived.
class DialogoEntrada extends StatefulWidget {
  const DialogoEntrada({
    super.key,
    required this.entradas,
    required this.existencias,
    this.proveedores = const [],
    this.proveedorInicial = '',
  });

  static const _ancho = 640.0;

  final ControladorEntradas entradas;
  final ControladorExistencias existencias;
  final List<String> proveedores;
  final String proveedorInicial;

  @override
  State<DialogoEntrada> createState() => _DialogoEntradaState();
}

class _DialogoEntradaState extends State<DialogoEntrada> {
  final _formulario = GlobalKey<FormState>();
  final _busqueda = TextEditingController();
  final _marca = TextEditingController();
  late final _proveedor = TextEditingController(text: widget.proveedorInicial);
  final _piezas = TextEditingController();
  final _cantidad = TextEditingController();
  final _nota = TextEditingController();
  final _focoBusqueda = FocusNode();
  final _focoMarca = FocusNode();
  final _focoProveedor = FocusNode();
  final _focoPiezas = FocusNode();
  final _focoCantidad = FocusNode();
  Producto? _producto;
  int? _lote;
  var _guardando = false;

  @override
  void dispose() {
    for (final c in [
      _busqueda,
      _marca,
      _proveedor,
      _piezas,
      _cantidad,
      _nota,
    ]) {
      c.dispose();
    }
    for (final f in [
      _focoBusqueda,
      _focoMarca,
      _focoProveedor,
      _focoPiezas,
      _focoCantidad,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  LoteMarca? get _loteElegido {
    final producto = _producto;
    final lote = _lote;
    return producto == null || lote == null ? null : producto.lotes[lote];
  }

  /// The brand of the supplier we came from, else the first brand.
  int? _loteInicial(Producto producto) {
    final proveedor = normalizarParaBusqueda(widget.proveedorInicial);
    if (proveedor.isEmpty) return producto.lotes.isEmpty ? null : 0;
    final i = producto.lotes.indexWhere(
      (l) => normalizarParaBusqueda(l.proveedor) == proveedor,
    );
    return i == -1 ? null : i;
  }

  // The fields only exist after the rebuild, so focus on the next frame.
  void _enfocarDespues(FocusNode Function() foco) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) foco().requestFocus();
      });

  void _enfocarCantidades() => _enfocarDespues(
    () => _lote == null
        ? _focoMarca
        : (_producto?.forma.cuentaPiezas ?? false)
        ? _focoPiezas
        : _focoCantidad,
  );

  void _elegirProducto(Producto producto) {
    setState(() {
      _producto = producto;
      _lote = _loteInicial(producto);
    });
    _enfocarCantidades();
  }

  void _elegirLote(int? lote) {
    setState(() => _lote = lote);
    _enfocarCantidades();
  }

  void _cambiarProducto() {
    setState(() {
      _producto = null;
      _lote = null;
    });
    _busqueda.clear();
    _enfocarDespues(() => _focoBusqueda);
  }

  /// Null until the fields hold a complete entry.
  Entrada? _leerEntrada() {
    final producto = _producto;
    if (producto == null) return null;
    final lote = _loteElegido;
    final forma = producto.forma;
    final piezas = forma.cuentaPiezas
        ? CampoCantidadRecibida.leer(_piezas, 0)
        : 0;
    final cantidad = CampoCantidadRecibida.leer(
      _cantidad,
      forma.unidad.decimales,
      unidad: forma.unidad,
    );
    final marca = lote?.marca ?? _marca.text.trim();
    if (marca.isEmpty || cantidad <= 0) return null;
    if (forma.cuentaPiezas && piezas <= 0) return null;
    return Entrada(
      marca: marca,
      proveedor: lote?.proveedor ?? _proveedor.text.trim(),
      piezas: piezas,
      cantidad: cantidad,
      nota: _nota.text.trim(),
    );
  }

  Future<void> _registrar({required bool otra}) async {
    if (_guardando || !(_formulario.currentState?.validate() ?? false)) return;
    final producto = _producto;
    final entrada = _leerEntrada();
    if (producto == null || entrada == null) return;
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final resultado = await widget.entradas.registrar(producto.id, entrada);
    if (!mounted) return;
    setState(() => _guardando = false);
    switch (resultado) {
      case EntradaRegistrada(:final producto):
        mostrarEntradaRegistrada(mensajero, widget.entradas, producto, entrada);
        if (!otra) {
          navegador.pop();
          return;
        }
        _formulario.currentState?.reset();
        _proveedor.text = widget.proveedorInicial;
        _cambiarProducto();
      case ProductoNoEncontrado():
        mensajero.showSnackBar(
          const SnackBar(content: Text('Ese producto ya no existe')),
        );
        _cambiarProducto();
    }
  }

  // Ctrl+Enter also submits the field; the shortcut already handles it.
  void _enterEnNota() {
    if (HardwareKeyboard.instance.isControlPressed) return;
    unawaited(_registrar(otra: false));
  }

  void _atajoMarca(int indice) {
    final producto = _producto;
    if (producto == null || indice > producto.lotes.length) return;
    _elegirLote(indice == producto.lotes.length ? null : indice);
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    for (final (i, tecla) in _teclasMarca.indexed)
      SingleActivator(tecla, alt: true): () => _atajoMarca(i),
    const SingleActivator(LogicalKeyboardKey.enter, control: true): () =>
        unawaited(_registrar(otra: true)),
    const SingleActivator(LogicalKeyboardKey.numpadEnter, control: true): () =>
        unawaited(_registrar(otra: true)),
  };

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
          constraints: const BoxConstraints(maxWidth: DialogoEntrada._ancho),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(espaciado.xl),
            child: Form(
              key: _formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: espaciado.lg,
                children: [
                  const EncabezadoDialogo(
                    titulo: 'Registrar entrada',
                    icono: Icons.download_outlined,
                  ),
                  if (producto == null)
                    BuscadorProductoEntrada(
                      productos: widget.existencias.productos,
                      controller: _busqueda,
                      focusNode: _focoBusqueda,
                      onElegir: _elegirProducto,
                      validator: (_) => 'Elige un producto de la lista',
                    )
                  else ...[
                    ProductoElegido(
                      producto: producto,
                      onCambiar: _cambiarProducto,
                    ),
                    ConEtiqueta(
                      etiqueta: 'Marca',
                      ayuda:
                          'Alt+1… elige la marca\n'
                          'Otra marca: una marca o proveedor nuevo',
                      child: ExcludeFocus(
                        child: OpcionesMarca(
                          producto: producto,
                          elegido: _lote,
                          onElegir: _elegirLote,
                        ),
                      ),
                    ),
                    CamposEntrada(
                      forma: producto.forma,
                      lote: _loteElegido,
                      marca: _marca,
                      proveedor: _proveedor,
                      piezas: _piezas,
                      cantidad: _cantidad,
                      nota: _nota,
                      focoMarca: _focoMarca,
                      focoProveedor: _focoProveedor,
                      focoPiezas: _focoPiezas,
                      focoCantidad: _focoCantidad,
                      proveedores: widget.proveedores,
                      onEnviar: _enterEnNota,
                    ),
                    ListenableBuilder(
                      listenable: Listenable.merge([
                        _marca,
                        _proveedor,
                        _piezas,
                        _cantidad,
                      ]),
                      builder: (context, _) {
                        final entrada = _leerEntrada();
                        return entrada == null
                            ? const SizedBox.shrink()
                            : VistaPreviaEntrada(
                                producto: producto,
                                entrada: entrada,
                              );
                      },
                    ),
                  ],
                  BotonesCrear(
                    etiqueta: 'Registrar',
                    etiquetaOtro: 'Registrar y otra',
                    guardando: _guardando,
                    onCrear: () => unawaited(_registrar(otra: false)),
                    onCrearOtro: () => unawaited(_registrar(otra: true)),
                  ),
                  Text(
                    'Escribe el producto · Alt+1… marca · Enter siguiente '
                    'campo · Ctrl+Enter registra y deja lista otra · Esc cierra',
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
