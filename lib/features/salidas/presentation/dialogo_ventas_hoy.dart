import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/salidas/application/controlador_devoluciones.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/domain/devolucion_cliente.dart';
import 'package:inventario/features/salidas/domain/devolver_venta.dart';
import 'package:inventario/features/salidas/domain/grupo_ventas.dart';
import 'package:inventario/features/salidas/domain/resultado_anulacion.dart';
import 'package:inventario/features/salidas/domain/venta.dart';
import 'package:inventario/features/salidas/presentation/confirmar_anulacion.dart';
import 'package:inventario/features/salidas/presentation/dialogo_devolucion.dart';
import 'package:inventario/features/salidas/presentation/encabezado_ticket.dart';
import 'package:inventario/features/salidas/presentation/fila_venta_hoy.dart';
import 'package:inventario/features/salidas/presentation/selector_dia_ventas.dart';

Future<void> mostrarVentasDeHoy(
  BuildContext context, {
  required ControladorMovimientos movimientos,
  required ControladorSalidas salidas,
  required ControladorExistencias existencias,
  ControladorDevoluciones? devoluciones,
  int? Function(int)? aBolivares,
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoVentasHoy(
    movimientos: movimientos,
    salidas: salidas,
    existencias: existencias,
    devoluciones: devoluciones,
    aBolivares: aBolivares,
  ),
);

/// A row of the list: a ticket's header, or one of its lines by position.
typedef _Fila = ({GrupoVentas grupo, int? linea});

/// F7 "Ventas": any day's sales grouped by ticket (Alt+← → change the day,
/// Ctrl+K filters by product). Alt+D returns a line; Supr cancels one of
/// today's after asking.
class DialogoVentasHoy extends StatefulWidget {
  const DialogoVentasHoy({
    super.key,
    required this.movimientos,
    required this.salidas,
    required this.existencias,
    this.devoluciones,
    this.aBolivares,
  });

  static const _ancho = 820.0;
  static const _altoLista = 460.0;

  final ControladorMovimientos movimientos;
  final ControladorSalidas salidas;
  final ControladorExistencias existencias;

  /// Customer returns with Alt+D; left out where returns are not offered.
  final ControladorDevoluciones? devoluciones;
  final int? Function(int)? aBolivares;

  @override
  State<DialogoVentasHoy> createState() => _DialogoVentasHoyState();
}

class _DialogoVentasHoyState extends State<DialogoVentasHoy> {
  final _filtro = TextEditingController();
  final _focoFiltro = FocusNode();
  late var _dia = widget.movimientos.hoy;
  var _elegida = 0;
  var _anulando = false;
  Map<String, Venta> _pagadas = const {};

  @override
  void initState() {
    super.initState();
    unawaited(_cargarPagos());
  }

  @override
  void dispose() {
    _filtro.dispose();
    _focoFiltro.dispose();
    super.dispose();
  }

  Future<void> _cargarPagos() async {
    final pagadas = await widget.salidas.ventasRegistradas();
    if (mounted) setState(() => _pagadas = pagadas);
  }

  bool get _esHoy => diasEntre(_dia, widget.movimientos.hoy) == 0;

  List<GrupoVentas> get _grupos => agruparPorTicket(
    widget.movimientos.ventasDelDia(_dia),
    filtro: _filtro.text,
  );

  List<Movimiento> get _lineas => [for (final g in _grupos) ...g.lineas];

  void _mover(int pasos) {
    final total = _lineas.length;
    if (total == 0) return;
    setState(() => _elegida = (_elegida + pasos).clamp(0, total - 1));
  }

  void _cambiarDia(DateTime dia) {
    if (diasEntre(dia, widget.movimientos.hoy) < 0) return;
    setState(() {
      _dia = dia;
      _elegida = 0;
    });
  }

  void _moverDia(int dias) =>
      _cambiarDia(DateTime(_dia.year, _dia.month, _dia.day + dias));

  /// How the product would be left once the goods are back.
  String? _quedara(Movimiento venta) {
    final producto = widget.existencias.productos
        .where((p) => p.id == venta.productoId)
        .firstOrNull;
    if (producto == null) return null;
    return textoStock(
      devolverVenta(
        producto,
        marca: venta.marca,
        proveedor: venta.proveedor,
        piezas: venta.piezas,
        cantidad: venta.cantidad,
        abrioPieza: venta.abrioPieza,
      ),
    );
  }

  Future<void> _anular(Movimiento venta) async {
    if (_anulando || venta.anulada || !_esHoy) return;
    final mensajero = ScaffoldMessenger.of(context);
    final confirmada = await confirmarAnulacion(
      context,
      venta: venta,
      quedara: _quedara(venta),
    );
    if (!confirmada || !mounted) return;
    setState(() => _anulando = true);
    final resultado = await widget.salidas.anular(venta);
    if (!mounted) return;
    setState(() => _anulando = false);
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(switch (resultado) {
            VentaAnulada() =>
              'Venta anulada · se devolvieron '
                  '${venta.forma.unidad.formatear(venta.cantidad)} '
                  'de ${venta.producto}',
            YaAnulada() => 'Esa venta ya estaba anulada',
            AnulacionConDevolucion() =>
              'No se puede anular: ya tiene una devolución. Devuelve el '
                  'resto con Alt+D',
            AnulacionSinProducto() =>
              'No se pudo anular: el producto ya no existe',
          }),
        ),
      );
  }

  bool _puedeDevolver(Movimiento venta) =>
      (widget.devoluciones?.devolvibleDe(venta) ?? 0) > 0;

  void _devolver(Movimiento venta) {
    final devoluciones = widget.devoluciones;
    if (devoluciones == null || !_puedeDevolver(venta)) return;
    unawaited(
      mostrarDialogoDevolucion(
        context,
        devoluciones: devoluciones,
        venta: venta,
        pagada: _pagadas[venta.ventaId],
        aBolivares: widget.aBolivares,
      ),
    );
  }

  void _conElegida(void Function(Movimiento) accion) {
    final lineas = _lineas;
    if (_elegida < lineas.length) accion(lineas[_elegida]);
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    const SingleActivator(LogicalKeyboardKey.keyD, alt: true): () =>
        _conElegida(_devolver),
    const SingleActivator(LogicalKeyboardKey.arrowUp): () => _mover(-1),
    const SingleActivator(LogicalKeyboardKey.arrowDown): () => _mover(1),
    const SingleActivator(LogicalKeyboardKey.delete): () =>
        _conElegida((v) => unawaited(_anular(v))),
    const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true): () =>
        _moverDia(-1),
    const SingleActivator(LogicalKeyboardKey.arrowRight, alt: true): () =>
        _moverDia(1),
    const SingleActivator(LogicalKeyboardKey.keyK, control: true):
        _focoFiltro.requestFocus,
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: _atajos,
        // While typing the filter, Supr and arrows belong to the field.
        activo: () => !_focoFiltro.hasFocus,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DialogoVentasHoy._ancho),
          child: Padding(
            padding: EdgeInsets.all(espaciado.xl),
            child: ListenableBuilder(
              listenable: Listenable.merge([widget.movimientos, _filtro]),
              builder: (context, _) {
                final grupos = _grupos;
                final filas = <_Fila>[];
                var linea = 0;
                for (final grupo in grupos) {
                  filas.add((grupo: grupo, linea: null));
                  for (final _ in grupo.lineas) {
                    filas.add((grupo: grupo, linea: linea++));
                  }
                }
                final lineas = [for (final g in grupos) ...g.lineas];
                final total = grupos.fold(0, (t, g) => t + g.total);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: espaciado.md,
                  children: [
                    const EncabezadoDialogo(
                      titulo: 'Ventas',
                      icono: Icons.receipt_long_outlined,
                    ),
                    SelectorDiaVentas(
                      dia: _dia,
                      hoy: widget.movimientos.hoy,
                      onCambiar: _cambiarDia,
                    ),
                    TextField(
                      controller: _filtro,
                      focusNode: _focoFiltro,
                      onSubmitted: (_) => _focoFiltro.unfocus(),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText:
                            'Filtrar por producto (Ctrl+K) · Enter '
                            'vuelve a la lista',
                      ),
                    ),
                    Text(
                      '${grupos.length} ventas · ${formatearDolares(total)} · '
                      '↑ ↓ elegir'
                      '${widget.devoluciones == null ? '' : ' · Alt+D devolver'}'
                      '${_esHoy ? ' · Supr anular' : ''}',
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                    if (filas.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: espaciado.xl),
                        child: Text(
                          _filtro.text.isEmpty
                              ? 'No hubo ventas ese día.'
                              : 'Ninguna venta de ese día tiene ese producto.',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.bodyLarge,
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: DialogoVentasHoy._altoLista,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filas.length,
                          itemBuilder: (context, i) {
                            final fila = filas[i];
                            final indice = fila.linea;
                            if (indice == null) {
                              return EncabezadoTicket(
                                grupo: fila.grupo,
                                pagada: _pagadas[fila.grupo.ventaId],
                              );
                            }
                            final venta = lineas[indice];
                            return FilaVentaHoy(
                              venta: venta,
                              elegida: indice == _elegida,
                              devuelto: yaDevuelto(
                                venta,
                                widget.movimientos.todos,
                              ),
                              onElegir: () => setState(() => _elegida = indice),
                              onDevolver: _puedeDevolver(venta)
                                  ? () => _devolver(venta)
                                  : null,
                              onAnular: _esHoy
                                  ? () => unawaited(_anular(venta))
                                  : null,
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
