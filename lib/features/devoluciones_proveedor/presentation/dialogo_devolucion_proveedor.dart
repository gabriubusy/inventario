import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/compras/presentation/editor_linea_compra.dart';
import 'package:inventario/features/compras/presentation/seccion_pago_compra.dart';
import 'package:inventario/features/compras/presentation/tabla_lineas_compra.dart';
import 'package:inventario/features/compras/presentation/total_compra.dart';
import 'package:inventario/features/devoluciones_proveedor/application/controlador_devoluciones_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/compensacion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/lineas_de_incidencia.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/motivo_devolucion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/resultado_devolucion_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/presentation/aviso_devolucion_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/presentation/seccion_compensacion.dart';
import 'package:inventario/features/devoluciones_proveedor/presentation/selector_motivo_devolucion.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/producto.dart';
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

/// Ctrl+D "Devolver a proveedor". [proveedorInicial] fills the supplier
/// (from its card); [incidencia] fills everything from an incident (F6).
Future<void> mostrarDialogoDevolucionProveedor(
  BuildContext context, {
  required ControladorDevolucionesProveedor devoluciones,
  required ControladorExistencias existencias,
  List<String> proveedores = const [],
  String proveedorInicial = '',
  Incidencia? incidencia,
  int? Function(int)? aBolivares,
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoDevolucionProveedor(
    devoluciones: devoluciones,
    existencias: existencias,
    proveedores: proveedores,
    proveedorInicial: incidencia?.proveedor ?? proveedorInicial,
    incidencia: incidencia,
    aBolivares: aBolivares,
  ),
);

/// Several products back to one supplier, then how it makes up for them.
class DialogoDevolucionProveedor extends StatefulWidget {
  const DialogoDevolucionProveedor({
    super.key,
    required this.devoluciones,
    required this.existencias,
    this.proveedores = const [],
    this.proveedorInicial = '',
    this.incidencia,
    this.aBolivares,
  });

  static const _ancho = 920.0;

  final ControladorDevolucionesProveedor devoluciones;
  final ControladorExistencias existencias;
  final List<String> proveedores;
  final String proveedorInicial;
  final Incidencia? incidencia;
  final int? Function(int)? aBolivares;

  @override
  State<DialogoDevolucionProveedor> createState() =>
      _DialogoDevolucionProveedorState();
}

class _DialogoDevolucionProveedorState
    extends State<DialogoDevolucionProveedor> {
  final _editor = GlobalKey<EditorLineaCompraState>();
  late final _proveedor = TextEditingController(text: widget.proveedorInicial);
  final _nota = TextEditingController();
  final _focoProveedor = FocusNode();
  late final _lineas = <LineaCompra>[
    if (widget.incidencia case final incidencia?)
      ...lineasDeIncidencia(incidencia, widget.existencias.productos),
  ];
  late var _motivo = motivoDeIncidencia(widget.incidencia);
  var _compensacion = Compensacion.descuento;
  var _medio = MedioPago.efectivoDolares;
  String? _compraId;
  String? _error;
  var _guardando = false;

  @override
  void initState() {
    super.initState();
    _proveedor.addListener(_refrescar);
  }

  @override
  void dispose() {
    _proveedor.dispose();
    _nota.dispose();
    _focoProveedor.dispose();
    super.dispose();
  }

  void _refrescar() => setState(() {});

  int get _total => _lineas.fold(0, (suma, l) => suma + l.subtotal);

  /// Only products this supplier brings that still have stock.
  List<Producto> get _productos {
    final clave = normalizarParaBusqueda(_proveedor.text);
    return [
      for (final p in widget.existencias.productos)
        if (p.lotes.any(
          (l) =>
              normalizarParaBusqueda(l.proveedor) == clave &&
              (l.cantidad > 0 || l.piezas > 0),
        ))
          p,
    ];
  }

  /// The chosen invoice, or the oldest still owed.
  String? get _compraElegida {
    final cuentas = widget.devoluciones.cuentasCon(_proveedor.text);
    if (cuentas.isEmpty) return null;
    return cuentas.any((c) => c.compra.id == _compraId)
        ? _compraId
        : cuentas.first.compra.id;
  }

  void _otraFactura() {
    final cuentas = widget.devoluciones.cuentasCon(_proveedor.text);
    if (cuentas.length < 2) return;
    final actual = cuentas.indexWhere((c) => c.compra.id == _compraElegida);
    setState(
      () => _compraId = cuentas[(actual + 1) % cuentas.length].compra.id,
    );
  }

  void _agregar(LineaCompra linea) => setState(() {
    _lineas.add(linea);
    _error = null;
  });

  Future<void> _registrar() async {
    final proveedor = _proveedor.text.trim();
    final error = proveedor.isEmpty
        ? 'Falta el proveedor'
        : _lineas.isEmpty
        ? 'Añade al menos un producto (Enter en el costo)'
        : null;
    setState(() => _error = error);
    if (error != null || _guardando) return;
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final resultado = await widget.devoluciones.registrar(
      proveedor: proveedor,
      motivo: _motivo,
      lineas: List.of(_lineas),
      compensacion: _compensacion,
      compraId: _compraElegida,
      medio: _medio,
      nota: _nota.text.trim(),
      incidencia: widget.incidencia,
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    switch (resultado) {
      case DevolucionRegistrada(:final devolucion):
        mostrarDevolucionRegistrada(mensajero, widget.devoluciones, devolucion);
        navegador.pop();
      case DevolucionNoAlcanza(:final producto):
        setState(() => _error = 'No hay tanto de $producto en esa marca');
      case DevolucionExcedeDeuda(:final debe):
        setState(
          () => _error =
              'La factura solo debe ${formatearDolares(debe)}: '
              'elige otra o devuelve dinero',
        );
      case DevolucionSinFactura():
        setState(() => _error = 'No hay factura a crédito que descontar');
      case DevolucionSinTasa():
        setState(() => _error = 'Falta la tasa de hoy (Ctrl+T en el inicio)');
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
    for (final (i, tecla) in teclasCompensacion.indexed)
      SingleActivator(tecla, alt: true): () =>
          setState(() => _compensacion = Compensacion.values[i]),
    for (final (i, tecla) in teclasMotivo.indexed)
      SingleActivator(tecla, alt: true): () =>
          setState(() => _motivo = MotivoDevolucion.values[i]),
    for (final (i, tecla) in teclasMedio.indexed)
      SingleActivator(tecla, alt: true): () {
        if (_compensacion == Compensacion.dinero) {
          setState(() => _medio = MedioPago.paraProveedores[i]);
        }
      },
    const SingleActivator(LogicalKeyboardKey.keyT, alt: true): _otraFactura,
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final error = _error;
    final desdeIncidencia = widget.incidencia != null;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: _atajos,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: DialogoDevolucionProveedor._ancho,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(espaciado.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: espaciado.lg,
              children: [
                const EncabezadoDialogo(
                  titulo: 'Devolver a proveedor',
                  icono: Icons.assignment_return_outlined,
                ),
                CampoProveedor(
                  controller: _proveedor,
                  focusNode: _focoProveedor,
                  sugerencias: widget.proveedores,
                  autofocus: widget.proveedorInicial.isEmpty,
                ),
                ConEtiqueta(
                  etiqueta: 'Por qué',
                  child: SelectorMotivoDevolucion(
                    motivo: _motivo,
                    onMotivo: (m) => setState(() => _motivo = m),
                  ),
                ),
                if (!desdeIncidencia)
                  ConEtiqueta(
                    etiqueta: 'Añadir producto',
                    child: EditorLineaCompra(
                      key: _editor,
                      productos: _productos,
                      proveedor: _proveedor.text,
                      onAgregar: _agregar,
                      conOtraMarca: false,
                    ),
                  ),
                TablaLineasCompra(
                  lineas: _lineas,
                  vacio: 'Aún no hay productos que devolver.',
                  onQuitar: (i) => setState(() => _lineas.removeAt(i)),
                ),
                TotalCompra(lineas: _lineas, aBolivares: widget.aBolivares),
                ConEtiqueta(
                  etiqueta: '¿Cómo lo compensa el proveedor?',
                  child: SeccionCompensacion(
                    compensacion: _compensacion,
                    cuentas: widget.devoluciones.cuentasCon(_proveedor.text),
                    compraId: _compraElegida,
                    medio: _medio,
                    total: _total,
                    hoy: widget.devoluciones.hoy,
                    onCompensacion: (c) => setState(() => _compensacion = c),
                    onCompra: (id) => setState(() => _compraId = id),
                    onMedio: (m) => setState(() => _medio = m),
                  ),
                ),
                TextField(
                  controller: _nota,
                  decoration: const InputDecoration(
                    labelText: 'Nota (opcional)',
                  ),
                ),
                if (error != null)
                  Text(
                    error,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: tema.colorScheme.error,
                    ),
                  ),
                BotonesCrear(
                  etiqueta: 'Registrar devolución',
                  atajo: 'Ctrl+S',
                  guardando: _guardando,
                  onCrear: () => unawaited(_registrar()),
                ),
                Text(
                  desdeIncidencia
                      ? 'Viene de la incidencia, que queda como "Se devolvió" '
                            '· Alt+Z–V por qué · Alt+Q/W/E cómo compensa · '
                            'Esc cierra'
                      : 'Enter en el costo añade el producto · Alt+1… marca · '
                            'Alt+Z–V por qué · Alt+Q/W/E cómo compensa · '
                            'Alt+A–G cómo devolvió el dinero · Esc cierra',
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
