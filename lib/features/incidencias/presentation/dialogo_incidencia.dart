import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/listas.dart';
import 'package:inventario/features/entradas/presentation/campo_cantidad_recibida.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/domain/datos_incidencia.dart';
import 'package:inventario/features/incidencias/domain/resultado_incidencia.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/incidencias/presentation/aviso_incidencia.dart';
import 'package:inventario/features/incidencias/presentation/campos_incidencia.dart';
import 'package:inventario/features/incidencias/presentation/opciones_suministro.dart';
import 'package:inventario/features/incidencias/presentation/selector_tipo_incidencia.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/presentation/campo_proveedor.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';
import 'package:inventario/features/proveedores/domain/suministro.dart';

const _teclasProducto = [
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

/// [proveedorInicial] fills the supplier (opened from its card).
Future<void> mostrarDialogoIncidencia(
  BuildContext context, {
  required ControladorIncidencias incidencias,
  required ControladorExistencias existencias,
  List<String> proveedores = const [],
  String proveedorInicial = '',
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoIncidencia(
    incidencias: incidencias,
    existencias: existencias,
    proveedores: proveedores,
    proveedorInicial: proveedorInicial,
  ),
);

/// Supplier, which of its products, what happened and how much.
class DialogoIncidencia extends StatefulWidget {
  const DialogoIncidencia({
    super.key,
    required this.incidencias,
    required this.existencias,
    this.proveedores = const [],
    this.proveedorInicial = '',
  });

  static const _ancho = 680.0;

  final ControladorIncidencias incidencias;
  final ControladorExistencias existencias;
  final List<String> proveedores;
  final String proveedorInicial;

  @override
  State<DialogoIncidencia> createState() => _DialogoIncidenciaState();
}

class _DialogoIncidenciaState extends State<DialogoIncidencia> {
  final _formulario = GlobalKey<FormState>();
  late final _proveedor = TextEditingController(text: widget.proveedorInicial);
  final _piezas = TextEditingController();
  final _cantidad = TextEditingController();
  final _nota = TextEditingController();
  final _focoProveedor = FocusNode();
  final _focoPiezas = FocusNode();
  final _focoCantidad = FocusNode();
  late List<Suministro> _suministros = _buscarSuministros();
  late int? _elegido = _suministros.length == 1 ? 0 : null;
  var _tipo = TipoIncidencia.malEstado;
  var _sacar = TipoIncidencia.malEstado.sacaDelInventario;
  var _faltaProducto = false;
  var _guardando = false;

  @override
  void initState() {
    super.initState();
    _proveedor.addListener(_alCambiarProveedor);
  }

  @override
  void dispose() {
    for (final c in [_proveedor, _piezas, _cantidad, _nota]) {
      c.dispose();
    }
    for (final f in [_focoProveedor, _focoPiezas, _focoCantidad]) {
      f.dispose();
    }
    super.dispose();
  }

  List<Suministro> _buscarSuministros() =>
      suministrosDelNombre(_proveedor.text, widget.existencias.productos);

  Suministro? get _suministro {
    final elegido = _elegido;
    return elegido == null ? null : _suministros[elegido];
  }

  void _alCambiarProveedor() {
    final nuevos = _buscarSuministros();
    if (listasIguales(nuevos, _suministros)) return;
    setState(() {
      _suministros = nuevos;
      _elegido = nuevos.length == 1 ? 0 : null;
    });
  }

  // The amount fields only exist after the rebuild.
  void _enfocarCantidades() =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final piezas = _suministro?.producto.forma.cuentaPiezas ?? false;
        (piezas ? _focoPiezas : _focoCantidad).requestFocus();
      });

  void _elegir(int indice) {
    if (indice >= _suministros.length) return;
    setState(() {
      _elegido = indice;
      _faltaProducto = false;
    });
    _enfocarCantidades();
  }

  void _elegirTipo(TipoIncidencia tipo) => setState(() {
    _tipo = tipo;
    _sacar = tipo.sacaDelInventario;
  });

  /// Null until the fields hold a complete incident.
  DatosIncidencia? _leer() {
    final suministro = _suministro;
    if (suministro == null) return null;
    final (:producto, :lote) = suministro;
    final forma = producto.forma;
    final cantidad = CampoCantidadRecibida.leer(
      _cantidad,
      forma.unidad.decimales,
      unidad: forma.unidad,
    );
    if (cantidad <= 0) return null;
    return DatosIncidencia(
      fecha: widget.incidencias.hoy,
      proveedor: lote.proveedor,
      productoId: producto.id,
      producto: producto.nombre,
      forma: forma,
      marca: lote.marca,
      tipo: _tipo,
      piezas: forma.cuentaPiezas ? CampoCantidadRecibida.leer(_piezas, 0) : 0,
      cantidad: cantidad,
      nota: _nota.text.trim(),
      sacada: _sacar,
    );
  }

  Future<void> _registrar() async {
    setState(() => _faltaProducto = _suministro == null);
    if (_guardando || !(_formulario.currentState?.validate() ?? false)) return;
    final datos = _leer();
    if (datos == null) return;
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final resultado = await widget.incidencias.registrar(datos);
    if (!mounted) return;
    setState(() => _guardando = false);
    switch (resultado) {
      case IncidenciaRegistrada(:final incidencia):
        mostrarIncidenciaRegistrada(mensajero, widget.incidencias, incidencia);
        navegador.pop();
      case ExistenciaInsuficiente():
        mensajero.showSnackBar(
          const SnackBar(
            content: Text('Ya no hay tanto de esa marca; revisa la cantidad'),
          ),
        );
        setState(() => _suministros = _buscarSuministros());
    }
  }

  // Ctrl+S may also arrive through the note; the shortcut handles it.
  void _enterEnNota() {
    if (HardwareKeyboard.instance.isControlPressed) return;
    unawaited(_registrar());
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    for (final (i, tecla) in _teclasProducto.indexed)
      SingleActivator(tecla, alt: true): () => _elegir(i),
    for (final (i, tecla) in teclasTipoIncidencia.indexed)
      SingleActivator(tecla, alt: true): () =>
          _elegirTipo(TipoIncidencia.values[i]),
    const SingleActivator(LogicalKeyboardKey.keyS, alt: true): () =>
        setState(() => _sacar = !_sacar),
    const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
        unawaited(_registrar()),
  };

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final tema = Theme.of(context);
    final suministro = _suministro;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: _atajos,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DialogoIncidencia._ancho),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(espaciado.xl),
            child: Form(
              key: _formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: espaciado.lg,
                children: [
                  const EncabezadoDialogo(
                    titulo: 'Registrar incidencia',
                    icono: Icons.report_problem_outlined,
                  ),
                  CampoProveedor(
                    controller: _proveedor,
                    focusNode: _focoProveedor,
                    sugerencias: widget.proveedores,
                    autofocus: widget.proveedorInicial.isEmpty,
                  ),
                  ConEtiqueta(
                    etiqueta: '¿Con qué producto?',
                    ayuda: 'Alt+1… elige el producto y su marca',
                    child: ExcludeFocus(
                      child: OpcionesSuministro(
                        suministros: _suministros,
                        elegido: _elegido,
                        onElegir: _elegir,
                      ),
                    ),
                  ),
                  if (_faltaProducto)
                    Text(
                      'Elige el producto (Alt+1…)',
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: tema.colorScheme.error,
                      ),
                    ),
                  ConEtiqueta(
                    etiqueta: '¿Qué pasó?',
                    ayuda: ayudaTipoIncidencia,
                    child: ExcludeFocus(
                      child: SelectorTipoIncidencia(
                        elegido: _tipo,
                        onElegir: _elegirTipo,
                      ),
                    ),
                  ),
                  if (suministro != null)
                    CamposIncidencia(
                      suministro: suministro,
                      piezas: _piezas,
                      cantidad: _cantidad,
                      nota: _nota,
                      focoPiezas: _focoPiezas,
                      focoCantidad: _focoCantidad,
                      sacar: _sacar,
                      onSacar: (valor) => setState(() => _sacar = valor),
                      onEnviar: _enterEnNota,
                    ),
                  Text(
                    'Queda abierta hasta que el proveedor responda',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  BotonesCrear(
                    etiqueta: 'Registrar incidencia',
                    atajo: 'Ctrl+S',
                    guardando: _guardando,
                    onCrear: () => unawaited(_registrar()),
                  ),
                  Text(
                    'Alt+1… producto · Alt+Q–T qué pasó · Alt+S sacar del '
                    'inventario · Enter siguiente campo · Esc cierra',
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
