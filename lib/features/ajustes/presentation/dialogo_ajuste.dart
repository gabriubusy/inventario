import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/ajustes/application/controlador_ajustes.dart';
import 'package:inventario/features/ajustes/domain/ajuste.dart';
import 'package:inventario/features/ajustes/domain/resultado_ajuste.dart';
import 'package:inventario/features/ajustes/domain/tipo_ajuste.dart';
import 'package:inventario/features/ajustes/presentation/aviso_ajuste.dart';
import 'package:inventario/features/ajustes/presentation/campos_ajuste.dart';
import 'package:inventario/features/ajustes/presentation/selector_motivo.dart';
import 'package:inventario/features/ajustes/presentation/selector_tipo_ajuste.dart';
import 'package:inventario/features/entradas/presentation/buscador_producto_entrada.dart';
import 'package:inventario/features/entradas/presentation/campo_cantidad_recibida.dart';
import 'package:inventario/features/entradas/presentation/producto_elegido.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';
import 'package:inventario/features/salidas/presentation/opciones_marca_salida.dart';

const _teclasMarca = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
];

Future<void> mostrarDialogoAjuste(
  BuildContext context, {
  required ControladorAjustes ajustes,
  required ControladorExistencias existencias,
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoAjuste(ajustes: ajustes, existencias: existencias),
);

/// F3: a merma or loss of one product and brand, out of the stock.
class DialogoAjuste extends StatefulWidget {
  const DialogoAjuste({
    super.key,
    required this.ajustes,
    required this.existencias,
  });

  static const _ancho = 640.0;

  final ControladorAjustes ajustes;
  final ControladorExistencias existencias;

  @override
  State<DialogoAjuste> createState() => _DialogoAjusteState();
}

class _DialogoAjusteState extends State<DialogoAjuste> {
  final _formulario = GlobalKey<FormState>();
  final _busqueda = TextEditingController();
  final _piezas = TextEditingController();
  final _cantidad = TextEditingController();
  final _nota = TextEditingController();
  final _focoBusqueda = FocusNode();
  final _focoPiezas = FocusNode();
  final _focoCantidad = FocusNode();
  var _tipo = TipoAjuste.merma;
  var _motivo = TipoAjuste.merma.motivos.first;
  Producto? _producto;
  int? _lote;
  var _guardando = false;

  @override
  void dispose() {
    for (final c in [_busqueda, _piezas, _cantidad, _nota]) {
      c.dispose();
    }
    for (final f in [_focoBusqueda, _focoPiezas, _focoCantidad]) {
      f.dispose();
    }
    super.dispose();
  }

  // The amount fields only exist after the rebuild.
  void _enfocarDespues(FocusNode foco) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) foco.requestFocus();
      });

  void _enfocarCantidades() => _enfocarDespues(
    (_producto?.forma.cuentaPiezas ?? false) ? _focoPiezas : _focoCantidad,
  );

  void _elegirProducto(Producto producto) {
    final conStock = producto.lotes.indexWhere((l) => l.tieneExistencia);
    setState(() {
      _producto = producto;
      _lote = conStock == -1 ? (producto.lotes.isEmpty ? null : 0) : conStock;
    });
    _enfocarCantidades();
  }

  void _elegirLote(int indice) {
    final producto = _producto;
    if (producto == null || indice >= producto.lotes.length) return;
    setState(() => _lote = indice);
    _enfocarCantidades();
  }

  void _elegirTipo(TipoAjuste tipo) => setState(() {
    _tipo = tipo;
    _motivo = tipo.motivos.first;
  });

  void _elegirMotivo(int indice) {
    if (indice < _tipo.motivos.length) {
      setState(() => _motivo = _tipo.motivos[indice]);
    }
  }

  void _cambiarProducto() {
    setState(() {
      _producto = null;
      _lote = null;
    });
    _busqueda.clear();
    _enfocarDespues(_focoBusqueda);
  }

  Ajuste? _leer() {
    final producto = _producto;
    final indice = _lote;
    if (producto == null || indice == null) return null;
    final lote = producto.lotes[indice];
    final forma = producto.forma;
    final cantidad = CampoCantidadRecibida.leer(
      _cantidad,
      forma.unidad.decimales,
      unidad: forma.unidad,
    );
    if (cantidad <= 0) return null;
    return Ajuste(
      tipo: _tipo,
      motivo: _motivo,
      marca: lote.marca,
      proveedor: lote.proveedor,
      piezas: forma.cuentaPiezas ? CampoCantidadRecibida.leer(_piezas, 0) : 0,
      cantidad: cantidad,
      nota: _nota.text.trim(),
    );
  }

  Future<void> _registrar() async {
    if (_guardando || !(_formulario.currentState?.validate() ?? false)) return;
    final producto = _producto;
    final ajuste = _leer();
    if (producto == null || ajuste == null) return;
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final resultado = await widget.ajustes.registrar(producto.id, ajuste);
    if (!mounted) return;
    setState(() => _guardando = false);
    switch (resultado) {
      case AjusteRegistrado(:final producto):
        mostrarAjusteRegistrado(mensajero, widget.ajustes, producto, ajuste);
        navegador.pop();
      case AjusteSinExistencias():
        mensajero.showSnackBar(
          const SnackBar(
            content: Text('Ya no hay tanto de esa marca; revisa la cantidad'),
          ),
        );
    }
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    // Ctrl+S saves in every window of the app.
    const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
        unawaited(_registrar()),
    for (final (i, tecla) in teclasTipoAjuste.indexed)
      SingleActivator(tecla, alt: true): () =>
          _elegirTipo(TipoAjuste.values[i]),
    for (final (i, tecla) in teclasMotivo.indexed)
      SingleActivator(tecla, alt: true): () => _elegirMotivo(i),
    for (final (i, tecla) in _teclasMarca.indexed)
      SingleActivator(tecla, alt: true): () => _elegirLote(i),
  };

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final tema = Theme.of(context);
    final producto = _producto;
    final lote = _lote;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: _atajos,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DialogoAjuste._ancho),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(espaciado.xl),
            child: Form(
              key: _formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: espaciado.lg,
                children: [
                  const EncabezadoDialogo(
                    titulo: 'Registrar merma o pérdida',
                    icono: Icons.delete_outline,
                  ),
                  ConEtiqueta(
                    etiqueta: 'Qué pasó',
                    ayuda: ayudaTipoAjuste,
                    child: ExcludeFocus(
                      child: SelectorTipoAjuste(
                        elegido: _tipo,
                        onElegir: _elegirTipo,
                      ),
                    ),
                  ),
                  ConEtiqueta(
                    etiqueta: 'Motivo',
                    ayuda: ayudaMotivos(_tipo.motivos),
                    child: ExcludeFocus(
                      child: SelectorMotivo(
                        motivos: _tipo.motivos,
                        elegido: _motivo,
                        onElegir: (m) => setState(() => _motivo = m),
                      ),
                    ),
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
                    if (producto.lotes.isEmpty)
                      Text(
                        'Este producto no tiene marcas con existencia.',
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.error,
                        ),
                      )
                    else
                      ConEtiqueta(
                        etiqueta: 'Marca',
                        ayuda: ayudaMarcas(producto),
                        child: ExcludeFocus(
                          child: OpcionesMarcaSalida(
                            producto: producto,
                            elegido: lote,
                            onElegir: _elegirLote,
                          ),
                        ),
                      ),
                    if (lote != null)
                      CamposAjuste(
                        producto: producto,
                        lote: producto.lotes[lote],
                        piezas: _piezas,
                        cantidad: _cantidad,
                        nota: _nota,
                        focoPiezas: _focoPiezas,
                        focoCantidad: _focoCantidad,
                        onEnviar: () => unawaited(_registrar()),
                      ),
                  ],
                  BotonesCrear(
                    etiqueta: 'Registrar ${_tipo.etiqueta.toLowerCase()}',
                    atajo: 'Ctrl+S',
                    guardando: _guardando,
                    onCrear: () => unawaited(_registrar()),
                  ),
                  Text(
                    'Alt+Q merma · Alt+W robo · Alt+A–F motivo · Alt+1… marca '
                    '· Enter registra · Esc cierra',
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
