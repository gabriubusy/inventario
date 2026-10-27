import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/compras/domain/resultados_compra.dart';
import 'package:inventario/features/compras/presentation/aviso_compra.dart';
import 'package:inventario/features/compras/presentation/editor_linea_compra.dart';
import 'package:inventario/features/compras/presentation/seccion_pago_compra.dart';
import 'package:inventario/features/compras/presentation/tabla_lineas_compra.dart';
import 'package:inventario/features/compras/presentation/total_compra.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/presentation/campo_proveedor.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';

const _teclasMarca = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
];

/// F2 "Pedido a proveedor": [proveedorInicial] fills the supplier (opened from its card).
Future<void> mostrarDialogoCompra(
  BuildContext context, {
  required ControladorCompras compras,
  required ControladorExistencias existencias,
  List<String> proveedores = const [],
  String proveedorInicial = '',
  int? Function(int)? aBolivares,
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoCompra(
    compras: compras,
    existencias: existencias,
    proveedores: proveedores,
    proveedorInicial: proveedorInicial,
    aBolivares: aBolivares,
  ),
);

/// A supplier's invoice: several products, then cash or credit.
class DialogoCompra extends StatefulWidget {
  const DialogoCompra({
    super.key,
    required this.compras,
    required this.existencias,
    this.proveedores = const [],
    this.proveedorInicial = '',
    this.aBolivares,
  });

  static const _ancho = 920.0;
  static const _diasCredito = '15';

  final ControladorCompras compras;
  final ControladorExistencias existencias;
  final List<String> proveedores;
  final String proveedorInicial;
  final int? Function(int)? aBolivares;

  @override
  State<DialogoCompra> createState() => _DialogoCompraState();
}

class _DialogoCompraState extends State<DialogoCompra> {
  final _editor = GlobalKey<EditorLineaCompraState>();
  late final _proveedor = TextEditingController(text: widget.proveedorInicial);
  final _factura = TextEditingController();
  final _dias = TextEditingController(text: DialogoCompra._diasCredito);
  final _focoProveedor = FocusNode();
  final _lineas = <LineaCompra>[];
  var _credito = true;
  var _medio = MedioPago.efectivoDolares;
  String? _error;
  var _guardando = false;

  @override
  void initState() {
    super.initState();
    _proveedor.addListener(_refrescar);
    _dias.addListener(_refrescar);
  }

  @override
  void dispose() {
    _proveedor.dispose();
    _factura.dispose();
    _dias.dispose();
    _focoProveedor.dispose();
    super.dispose();
  }

  void _refrescar() => setState(() {});

  DateTime? get _vence {
    final dias = int.tryParse(_dias.text);
    if (dias == null || dias <= 0) return null;
    final hoy = widget.compras.hoy;
    return DateTime(hoy.year, hoy.month, hoy.day + dias);
  }

  void _agregar(LineaCompra linea) => setState(() {
    _lineas.add(linea);
    _error = null;
  });

  Future<void> _registrar() async {
    final proveedor = _proveedor.text.trim();
    final vence = _vence;
    final error = proveedor.isEmpty
        ? 'Falta el proveedor'
        : _lineas.isEmpty
        ? 'Añade al menos un producto (Enter en el costo)'
        : _credito && vence == null
        ? 'Escribe en cuántos días vence'
        : null;
    setState(() => _error = error);
    if (error != null || _guardando) return;
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final resultado = await widget.compras.registrar(
      Compra(
        fecha: widget.compras.hoy,
        proveedor: proveedor,
        factura: _factura.text.trim(),
        lineas: List.of(_lineas),
        vence: _credito ? vence : null,
        medio: _credito ? null : _medio,
      ),
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    switch (resultado) {
      case CompraRegistrada(:final compra):
        mostrarCompraRegistrada(mensajero, widget.compras, compra);
        navegador.pop();
      case CompraSinProducto(:final producto):
        setState(() => _error = '$producto ya no existe; quítalo de la lista');
    }
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    for (final (i, tecla) in _teclasMarca.indexed)
      SingleActivator(tecla, alt: true): () =>
          _editor.currentState?.elegirMarca(i),
    const SingleActivator(LogicalKeyboardKey.enter, control: true): () =>
        _editor.currentState?.agregar(),
    const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
        unawaited(_registrar()),
    const SingleActivator(LogicalKeyboardKey.keyQ, alt: true): () =>
        setState(() => _credito = false),
    const SingleActivator(LogicalKeyboardKey.keyW, alt: true): () =>
        setState(() => _credito = true),
    for (final (i, tecla) in teclasMedio.indexed)
      SingleActivator(tecla, alt: true): () {
        if (!_credito) {
          setState(() => _medio = MedioPago.paraProveedores[i]);
        }
      },
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final error = _error;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: _atajos,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DialogoCompra._ancho),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(espaciado.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: espaciado.lg,
              children: [
                const EncabezadoDialogo(
                  titulo: 'Pedido a proveedor',
                  icono: Icons.download_outlined,
                ),
                Row(
                  spacing: espaciado.md,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CampoProveedor(
                        controller: _proveedor,
                        focusNode: _focoProveedor,
                        sugerencias: widget.proveedores,
                        autofocus: widget.proveedorInicial.isEmpty,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _factura,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'N° de factura (opcional)',
                        ),
                      ),
                    ),
                  ],
                ),
                ConEtiqueta(
                  etiqueta: 'Añadir producto',
                  child: EditorLineaCompra(
                    key: _editor,
                    productos: widget.existencias.productos,
                    proveedor: _proveedor.text,
                    onAgregar: _agregar,
                  ),
                ),
                TablaLineasCompra(
                  lineas: _lineas,
                  onQuitar: (i) => setState(() => _lineas.removeAt(i)),
                ),
                ConEtiqueta(
                  etiqueta: '¿Cómo se paga?',
                  child: SeccionPagoCompra(
                    credito: _credito,
                    dias: _dias,
                    vence: _vence,
                    medio: _medio,
                    onCredito: (c) => setState(() => _credito = c),
                    onMedio: (m) => setState(() => _medio = m),
                  ),
                ),
                TotalCompra(lineas: _lineas, aBolivares: widget.aBolivares),
                if (error != null)
                  Text(
                    error,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: tema.colorScheme.error,
                    ),
                  ),
                BotonesCrear(
                  etiqueta: 'Registrar pedido',
                  atajo: 'Ctrl+S',
                  guardando: _guardando,
                  onCrear: () => unawaited(_registrar()),
                ),
                Text(
                  'Enter siguiente campo · Enter en el costo añade el '
                  'producto · Alt+1… marca · Alt+Q contado · Alt+W crédito '
                  '· Alt+A–G cómo se pagó · Esc cierra',
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
    );
  }
}
