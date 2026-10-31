import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/entradas/presentation/campo_cantidad_recibida.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/presentation/textos_movimiento.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';
import 'package:inventario/features/salidas/application/controlador_devoluciones.dart';
import 'package:inventario/features/salidas/domain/devolucion_cliente.dart';
import 'package:inventario/features/salidas/domain/resultado_devolucion.dart';
import 'package:inventario/features/salidas/domain/venta.dart';
import 'package:inventario/features/salidas/presentation/opciones_medio_pago.dart';

/// Alt+Q back to the stock, Alt+W to merma.
const _teclasDestino = [LogicalKeyboardKey.keyQ, LogicalKeyboardKey.keyW];
const _letrasDestino = ['Q', 'W'];

/// What each destination means, shown on hover over its label.
final _ayudaDestino = [
  for (final (i, d) in DestinoDevolucion.values.indexed)
    '${d.etiqueta}: ${d.detalle.toLowerCase()} · Alt+${_letrasDestino[i]}',
].join('\n');

Future<void> mostrarDialogoDevolucion(
  BuildContext context, {
  required ControladorDevoluciones devoluciones,
  required Movimiento venta,
  Venta? pagada,
  int? Function(int)? aBolivares,
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoDevolucion(
    devoluciones: devoluciones,
    venta: venta,
    pagada: pagada,
    aBolivares: aBolivares,
  ),
);

/// A customer brings back all or part of a sale of any day, and says how
/// the money goes back (Alt+1…, offered as the sale was paid).
class DialogoDevolucion extends StatefulWidget {
  const DialogoDevolucion({
    super.key,
    required this.devoluciones,
    required this.venta,
    this.pagada,
    this.aBolivares,
  });

  static const _ancho = 640.0;

  final ControladorDevoluciones devoluciones;
  final Movimiento venta;

  /// The ticket the line belongs to, to know how it was paid.
  final Venta? pagada;

  /// Today's rate, only for sales that kept none.
  final int? Function(int)? aBolivares;

  @override
  State<DialogoDevolucion> createState() => _DialogoDevolucionState();
}

class _DialogoDevolucionState extends State<DialogoDevolucion> {
  final _formulario = GlobalKey<FormState>();
  late final int _maximo = widget.devoluciones.devolvibleDe(widget.venta);
  late final _cantidad = TextEditingController(
    text: formatDecimal(_maximo, decimales: _decimales),
  );
  final _nota = TextEditingController();
  final _focoCantidad = FocusNode();
  var _destino = DestinoDevolucion.stock;
  late var _medio = medioSugerido(widget.pagada);
  var _guardando = false;

  int get _decimales => widget.venta.forma.unidad.decimales;

  @override
  void initState() {
    super.initState();
    // Starts on the amount, all of it selected, ready to retype.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focoCantidad.requestFocus();
      _cantidad.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _cantidad.text.length,
      );
    });
  }

  @override
  void dispose() {
    _cantidad.dispose();
    _nota.dispose();
    _focoCantidad.dispose();
    super.dispose();
  }

  /// "Se le devuelven 5.494,63 Bs ($ 6,20 a la tasa de esa venta)", in the
  /// currency of the chosen way, for what is typed.
  String? get _reembolso {
    final cantidad = CampoCantidadRecibida.leer(
      _cantidad,
      _decimales,
      unidad: widget.venta.forma.unidad,
    );
    if (cantidad <= 0 || cantidad > _maximo) return null;
    final importe = widget.devoluciones.importeADevolver(
      widget.venta,
      cantidad,
    );
    if (importe == null) return 'La venta no tenía precio';
    final tasa = widget.venta.tasa;
    final monto =
        reembolsoEnMoneda(importe, _medio, tasa) ??
        widget.aBolivares?.call(importe);
    if (_medio.moneda == Moneda.dolares || monto == null) {
      return 'Se le devuelven ${formatearDolares(importe)}';
    }
    final aTasa = tasa == null ? 'a la tasa de hoy' : 'a la tasa de esa venta';
    return 'Se le devuelven ${formatearBolivares(monto)} '
        '(${formatearDolares(importe)} $aTasa)';
  }

  void _elegirMedio(MedioPago medio) => setState(() => _medio = medio);

  Future<void> _registrar() async {
    if (_guardando || !(_formulario.currentState?.validate() ?? false)) return;
    final cantidad = CampoCantidadRecibida.leer(
      _cantidad,
      _decimales,
      unidad: widget.venta.forma.unidad,
    );
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final resultado = await widget.devoluciones.devolver(
      widget.venta,
      cantidad: cantidad,
      destino: _destino,
      medio: _medio,
      nota: _nota.text.trim(),
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    final unidad = widget.venta.forma.unidad;
    switch (resultado) {
      case DevolucionRegistrada(:final importe):
        navegador.pop();
        mensajero
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Devolución registrada · ${widget.venta.producto} '
                '+${unidad.formatear(cantidad)} · ${_destino.etiqueta}'
                '${importe == null ? '' : ' · ${formatearDolares(importe)}'}',
              ),
              persist: false,
              action: SnackBarAction(
                label: 'Deshacer',
                onPressed: () => unawaited(widget.devoluciones.deshacer()),
              ),
            ),
          );
      case DevolucionExcede():
        mensajero.showSnackBar(
          const SnackBar(
            content: Text('Esa venta ya no tiene tanto que devolver'),
          ),
        );
      case DevolucionSinProducto():
        mensajero.showSnackBar(
          const SnackBar(content: Text('Ese producto ya no existe')),
        );
    }
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    // Ctrl+S saves in every window of the app.
    const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
        unawaited(_registrar()),
    for (final (i, tecla) in _teclasDestino.indexed)
      SingleActivator(tecla, alt: true): () =>
          setState(() => _destino = DestinoDevolucion.values[i]),
    for (final medio in mediosReembolso)
      SingleActivator(teclasMedioPago[medio.index], alt: true): () =>
          _elegirMedio(medio),
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final venta = widget.venta;
    final unidad = venta.forma.unidad;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: _atajos,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DialogoDevolucion._ancho),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(espaciado.xl),
            child: Form(
              key: _formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: espaciado.lg,
                children: [
                  const EncabezadoDialogo(
                    titulo: 'Devolución de cliente',
                    icono: Icons.assignment_return_outlined,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${venta.producto} · ${venta.marca}\n',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: [
                            'Vendido ${formatearFechaCorta(venta.fecha, DateTime.now())} '
                                'a las ${textoHora(venta.fecha)}',
                            textoDetalleMovimiento(venta),
                            if (venta.importe case final importe?)
                              formatearDolares(importe),
                            if (widget.pagada case final pagada?)
                              'pagó en ${pagada.pagos.map((p) => p.medio.etiqueta).toSet().join(' + ')}',
                          ].join(' · '),
                          style: TextStyle(color: colores.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  CampoCantidadRecibida(
                    etiqueta: 'Cuánto devuelve',
                    controller: _cantidad,
                    focusNode: _focoCantidad,
                    decimales: _decimales,
                    sufijo: unidad.simbolo,
                    unidad: unidad,
                    maximo: _maximo,
                  ),
                  ConEtiqueta(
                    etiqueta: 'Qué se hace con lo devuelto',
                    ayuda: _ayudaDestino,
                    child: ExcludeFocus(
                      child: Row(
                        spacing: espaciado.sm,
                        children: [
                          for (final destino in DestinoDevolucion.values)
                            Expanded(
                              child: OpcionSeleccionable(
                                titulo: destino.etiqueta,
                                elegida: destino == _destino,
                                onPulsar: () =>
                                    setState(() => _destino = destino),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  ConEtiqueta(
                    etiqueta: 'Cómo se le devuelve el dinero',
                    ayuda: ayudaMediosPago(mediosReembolso),
                    child: OpcionesMedioPago(
                      elegido: _medio,
                      onElegir: _elegirMedio,
                      medios: mediosReembolso,
                    ),
                  ),
                  ListenableBuilder(
                    listenable: _cantidad,
                    builder: (context, _) => Text(
                      _reembolso ?? '',
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _nota,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Motivo (opcional)',
                      hintText: 'No era el que pidió…',
                    ),
                    onFieldSubmitted: (_) => unawaited(_registrar()),
                  ),
                  BotonesCrear(
                    etiqueta: 'Registrar devolución',
                    atajo: 'Ctrl+S',
                    guardando: _guardando,
                    onCrear: () => unawaited(_registrar()),
                  ),
                  Text(
                    'Alt+Q vuelve al stock · Alt+W va a merma · Alt+1… '
                    'cómo se devuelve · Enter registra · Esc cierra',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: colores.onSurfaceVariant,
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
