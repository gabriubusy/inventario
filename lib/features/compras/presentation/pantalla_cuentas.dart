import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/domain/cuenta_por_pagar.dart';
import 'package:inventario/features/compras/presentation/dialogo_pago.dart';
import 'package:inventario/features/compras/presentation/fila_cuenta.dart';
import 'package:inventario/features/inicio/presentation/cifra_del_dia.dart';

/// F10: invoices bought on credit, what is still owed and when it is due.
class PantallaCuentas extends StatefulWidget {
  const PantallaCuentas({super.key, required this.compras, this.aBolivares});

  static const _anchoMaximo = 1240.0;

  final ControladorCompras compras;
  final int? Function(int)? aBolivares;

  @override
  State<PantallaCuentas> createState() => _PantallaCuentasState();
}

class _PantallaCuentasState extends State<PantallaCuentas> {
  final _busqueda = TextEditingController();
  final _focoBusqueda = FocusNode();
  var _pagadas = false;
  String? _elegidaId;

  @override
  void initState() {
    super.initState();
    _busqueda.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _busqueda.dispose();
    _focoBusqueda.dispose();
    super.dispose();
  }

  List<CuentaPorPagar> get _visibles {
    final buscado = normalizarParaBusqueda(_busqueda.text);
    return [
      for (final c in widget.compras.cuentas)
        if ((c.debe <= 0) == _pagadas &&
            (buscado.isEmpty ||
                normalizarParaBusqueda(c.compra.proveedor).contains(buscado) ||
                normalizarParaBusqueda(c.compra.factura).contains(buscado)))
          c,
    ];
  }

  CuentaPorPagar? get _elegida {
    final visibles = _visibles;
    if (visibles.isEmpty) return null;
    return visibles.firstWhere(
      (c) => c.compra.id == _elegidaId,
      orElse: () => visibles.first,
    );
  }

  void _mover(int pasos) {
    final visibles = _visibles;
    final actual = _elegida;
    if (actual == null) return;
    final destino = (visibles.indexOf(actual) + pasos).clamp(
      0,
      visibles.length - 1,
    );
    setState(() => _elegidaId = visibles[destino].compra.id);
  }

  void _pagar() {
    final elegida = _elegida;
    if (elegida == null || elegida.debe <= 0) return;
    unawaited(
      mostrarDialogoPago(context, compras: widget.compras, cuenta: elegida),
    );
  }

  void _volver() {
    if (_busqueda.text.isNotEmpty) {
      _busqueda.clear();
      return;
    }
    unawaited(Navigator.of(context).maybePop());
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    const SingleActivator(LogicalKeyboardKey.escape): _volver,
    const SingleActivator(LogicalKeyboardKey.keyK, control: true):
        _focoBusqueda.requestFocus,
    const SingleActivator(LogicalKeyboardKey.arrowUp): () => _mover(-1),
    const SingleActivator(LogicalKeyboardKey.arrowDown): () => _mover(1),
    const SingleActivator(LogicalKeyboardKey.keyP, alt: true): _pagar,
    const SingleActivator(LogicalKeyboardKey.keyA, alt: true): () =>
        setState(() => _pagadas = false),
    const SingleActivator(LogicalKeyboardKey.keyT, alt: true): () =>
        setState(() => _pagadas = true),
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return AtajosDeTeclado(
      atajos: _atajos,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cuentas por pagar'),
          actions: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: _busqueda,
                focusNode: _focoBusqueda,
                decoration: const InputDecoration(
                  hintText: 'Buscar proveedor o factura (Ctrl+K)',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(width: espaciado.xl),
          ],
        ),
        body: ListenableBuilder(
          listenable: widget.compras,
          builder: (context, _) {
            final hoy = widget.compras.hoy;
            final resumen = widget.compras.resumen;
            final visibles = _visibles;
            final elegida = _elegida;
            final enBs = widget.aBolivares?.call(resumen.debe);
            String facturas(int n) => n == 1 ? '1 factura' : '$n facturas';
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: PantallaCuentas._anchoMaximo,
                ),
                child: ListView(
                  padding: EdgeInsets.all(espaciado.xl),
                  children: [
                    Row(
                      spacing: espaciado.md,
                      children: [
                        Expanded(
                          child: CifraDelDia(
                            titulo: 'Debemos en total',
                            valor: formatearDolares(resumen.debe),
                            detalle: enBs == null
                                ? 'Sin tasa de hoy'
                                : '${formatearBolivares(enBs)} a la tasa de hoy',
                          ),
                        ),
                        Expanded(
                          child: CifraDelDia(
                            titulo: 'Vencido',
                            valor: formatearDolares(resumen.vencido),
                            detalle: facturas(resumen.vencidas),
                            color: resumen.vencidas > 0
                                ? context.coloresEstado.textoAgotado
                                : null,
                          ),
                        ),
                        Expanded(
                          child: CifraDelDia(
                            titulo: 'Vence en 7 días',
                            valor: formatearDolares(resumen.porVencer),
                            detalle: facturas(resumen.porVencerCuantas),
                            color: resumen.porVencerCuantas > 0
                                ? context.coloresEstado.textoBajo
                                : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: espaciado.lg),
                    Row(
                      spacing: espaciado.md,
                      children: [
                        Tooltip(
                          message: 'Por pagar · Alt+A\nPagadas · Alt+T',
                          child: ExcludeFocus(
                            child: SegmentedButton<bool>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: false,
                                  label: Text('Por pagar'),
                                ),
                                ButtonSegment(
                                  value: true,
                                  label: Text('Pagadas'),
                                ),
                              ],
                              selected: {_pagadas},
                              onSelectionChanged: (v) =>
                                  setState(() => _pagadas = v.first),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '↑ ↓ elegir',
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: colores.onSurfaceVariant,
                          ),
                        ),
                        FilledButton(
                          onPressed: elegida == null || elegida.debe <= 0
                              ? null
                              : _pagar,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 44),
                          ),
                          child: Row(
                            spacing: espaciado.sm,
                            children: [
                              const Text('Pagar o abonar'),
                              TeclaAtajo('Alt+P', color: colores.onPrimary),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: espaciado.md),
                    Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(espaciado.md),
                            child: ColumnasCuenta(
                              celdas: [
                                for (final (t, derecha) in const [
                                  ('PROVEEDOR', false),
                                  ('FACTURA', false),
                                  ('FECHA', false),
                                  ('TOTAL', true),
                                  ('ABONADO', true),
                                  ('DEBE', true),
                                  ('VENCE', false),
                                ])
                                  Text(
                                    t,
                                    textAlign: derecha
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: tema.textTheme.labelSmall?.copyWith(
                                      color: colores.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (visibles.isEmpty)
                            Padding(
                              padding: EdgeInsets.all(espaciado.xl),
                              child: Text(
                                _pagadas
                                    ? 'Aún no hay facturas pagadas'
                                    : 'No se le debe nada a nadie',
                                style: tema.textTheme.bodyMedium?.copyWith(
                                  color: colores.onSurfaceVariant,
                                ),
                              ),
                            ),
                          for (final cuenta in visibles)
                            FilaCuenta(
                              cuenta: cuenta,
                              hoy: hoy,
                              elegida: cuenta == elegida,
                              onElegir: () =>
                                  setState(() => _elegidaId = cuenta.compra.id),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
