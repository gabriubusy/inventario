import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/entradas/presentation/campo_cantidad_recibida.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/presentation/textos_movimiento.dart';
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';
import 'package:inventario/features/salidas/application/controlador_devoluciones.dart';
import 'package:inventario/features/salidas/domain/devolucion_cliente.dart';
import 'package:inventario/features/salidas/domain/resultado_devolucion.dart';

/// Alt+Q back to the stock, Alt+W to merma.
const _teclasDestino = [LogicalKeyboardKey.keyQ, LogicalKeyboardKey.keyW];

Future<void> mostrarDialogoDevolucion(
  BuildContext context, {
  required ControladorDevoluciones devoluciones,
  required Movimiento venta,
  int? Function(int)? aBolivares,
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoDevolucion(
    devoluciones: devoluciones,
    venta: venta,
    aBolivares: aBolivares,
  ),
);

/// A customer brings back all or part of one of today's sales.
class DialogoDevolucion extends StatefulWidget {
  const DialogoDevolucion({
    super.key,
    required this.devoluciones,
    required this.venta,
    this.aBolivares,
  });

  static const _ancho = 560.0;

  final ControladorDevoluciones devoluciones;
  final Movimiento venta;
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

  /// "Se le devuelven $ 37,80 · Bs 33.499,49" for what is typed.
  String? get _reembolso {
    final cantidad = CampoCantidadRecibida.leer(_cantidad, _decimales);
    if (cantidad <= 0 || cantidad > _maximo) return null;
    final importe = importeDevuelto(widget.venta, cantidad);
    if (importe == null) return 'La venta no tenía precio';
    final bolivares = widget.aBolivares?.call(importe);
    return 'Se le devuelven ${formatearDolares(importe)}'
        '${bolivares == null ? '' : ' · ${formatearBolivares(bolivares)}'}';
  }

  Future<void> _registrar() async {
    if (_guardando || !(_formulario.currentState?.validate() ?? false)) return;
    final cantidad = CampoCantidadRecibida.leer(_cantidad, _decimales);
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final resultado = await widget.devoluciones.devolver(
      widget.venta,
      cantidad: cantidad,
      destino: _destino,
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
    for (final (i, tecla) in _teclasDestino.indexed)
      SingleActivator(tecla, alt: true): () =>
          setState(() => _destino = DestinoDevolucion.values[i]),
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
                          text:
                              'Vendido a las ${textoHora(venta.fecha)} · '
                              '${textoDetalleMovimiento(venta)}'
                              '${venta.importe == null ? '' : ' · ${formatearDolares(venta.importe!)}'}',
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
                    maximo: _maximo,
                  ),
                  ListenableBuilder(
                    listenable: _cantidad,
                    builder: (context, _) => Text(
                      _reembolso ?? '',
                      style: tema.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  ExcludeFocus(
                    child: Row(
                      spacing: espaciado.sm,
                      children: [
                        for (final destino in DestinoDevolucion.values)
                          Expanded(
                            child: OpcionSeleccionable(
                              titulo: destino.etiqueta,
                              detalle: destino.detalle,
                              elegida: destino == _destino,
                              onPulsar: () =>
                                  setState(() => _destino = destino),
                            ),
                          ),
                      ],
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
                    guardando: _guardando,
                    onCrear: () => unawaited(_registrar()),
                  ),
                  Text(
                    'Alt+Q vuelve al stock · Alt+W va a merma · Enter '
                    'registra · Esc cierra',
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
