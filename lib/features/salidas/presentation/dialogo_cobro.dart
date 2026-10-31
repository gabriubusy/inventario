import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';
import 'package:inventario/features/salidas/domain/resultado_cobro.dart';
import 'package:inventario/features/salidas/domain/resumen_cobro.dart';
import 'package:inventario/features/salidas/presentation/lista_pagos.dart';
import 'package:inventario/features/salidas/presentation/opciones_medio_pago.dart';
import 'package:inventario/features/salidas/presentation/panel_cobro.dart';

/// Returns the result once the sale is registered; null if closed before.
Future<ResultadoCobro?> mostrarDialogoCobro(
  BuildContext context, {
  required int total,
  required int tasa,
  required MedioPago medioInicial,
  required Future<ResultadoCobro> Function(List<PagoVenta> pagos) onCobrar,
}) => showDialog<ResultadoCobro>(
  context: context,
  builder: (_) => DialogoCobro(
    total: total,
    tasa: tasa,
    medioInicial: medioInicial,
    onCobrar: onCobrar,
  ),
);

/// F10 from the sale: pick how it is paid (Alt+1…), type what was handed
/// over (empty = exact) and Enter. Ctrl+M adds another payment.
class DialogoCobro extends StatefulWidget {
  const DialogoCobro({
    super.key,
    required this.total,
    required this.tasa,
    required this.medioInicial,
    required this.onCobrar,
  });

  static const _ancho = 760.0;
  static const _anchoMonto = 240.0;
  static const _anchoReferencia = 200.0;

  /// Dollar hundredths.
  final int total;

  /// Bs per dollar, hundredths.
  final int tasa;
  final MedioPago medioInicial;
  final Future<ResultadoCobro> Function(List<PagoVenta> pagos) onCobrar;

  @override
  State<DialogoCobro> createState() => _DialogoCobroState();
}

class _DialogoCobroState extends State<DialogoCobro> {
  final _monto = TextEditingController();
  final _referencia = TextEditingController();
  final _focoMonto = FocusNode();
  late var _medio = widget.medioInicial;
  var _pagos = <PagoVenta>[];
  var _registrando = false;

  @override
  void dispose() {
    _monto.dispose();
    _referencia.dispose();
    _focoMonto.dispose();
    super.dispose();
  }

  ResumenCobro _resumenCon(List<PagoVenta> pagos) =>
      ResumenCobro(total: widget.total, pagos: pagos, tasa: widget.tasa);

  /// What is still owed, in the chosen way's currency.
  int get _faltaEnMoneda {
    final cobro = _resumenCon(_pagos);
    return switch (_medio.moneda) {
      Moneda.dolares => cobro.falta,
      Moneda.bolivares => cobro.faltaEnBolivares,
    };
  }

  /// The payment being typed; an empty amount pays exactly what is owed.
  PagoVenta? get _pagoEnCurso {
    final escrito = parseDecimal(_monto.text, decimales: decimalesDinero);
    final monto = escrito ?? _faltaEnMoneda;
    if (monto <= 0) return null;
    return PagoVenta(
      medio: _medio,
      monto: monto,
      referencia: _medio.conReferencia ? _referencia.text.trim() : '',
    );
  }

  List<PagoVenta> get _todos => [..._pagos, ?_pagoEnCurso];

  void _elegirMedio(MedioPago medio) {
    setState(() => _medio = medio);
    _focoMonto.requestFocus();
  }

  void _agregarPago() {
    final pago = _pagoEnCurso;
    if (pago == null) return;
    setState(() => _pagos = [..._pagos, pago]);
    _monto.clear();
    _referencia.clear();
    _focoMonto.requestFocus();
  }

  void _quitarPago(int indice) => setState(
    () => _pagos = [
      for (final (i, p) in _pagos.indexed)
        if (i != indice) p,
    ],
  );

  /// A typed amount that doesn't cover the total.
  bool get _escritoCorto =>
      _monto.text.trim().isNotEmpty && _resumenCon(_todos).falta > 0;

  Future<void> _registrar() async {
    // Enter never does nothing: a short amount is one payment of several.
    if (_escritoCorto) return _agregarPago();
    final pagos = _todos;
    if (_registrando || !_resumenCon(pagos).puedeRegistrarse) return;
    setState(() => _registrando = true);
    final resultado = await widget.onCobrar(pagos);
    if (!mounted) return;
    setState(() => _registrando = false);
    // Only a full sale closes the window; otherwise the sale says why.
    if (resultado is VentaCobrada || resultado is CobroSinExistencias) {
      Navigator.of(context).pop(resultado);
    }
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    for (final (i, medio) in MedioPago.values.indexed)
      SingleActivator(teclasMedioPago[i], alt: true): () => _elegirMedio(medio),
    const SingleActivator(LogicalKeyboardKey.keyM, control: true): _agregarPago,
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final cobro = _resumenCon(_todos);
    // With the amount empty, show what is owed; Enter still pays it exactly.
    final mostrado = _monto.text.trim().isEmpty ? _resumenCon(_pagos) : cobro;
    final simbolo = _medio.moneda == Moneda.dolares ? '\$' : 'Bs';
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: _atajos,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DialogoCobro._ancho),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(espaciado.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: espaciado.lg,
              children: [
                const EncabezadoDialogo(
                  titulo: 'Cobrar',
                  icono: Icons.point_of_sale_outlined,
                ),
                Text(
                  'Total ${formatearDolares(widget.total)} · '
                  '${formatearBolivares(dividirRedondeando(widget.total * widget.tasa, 100))}',
                  style: tema.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                ConEtiqueta(
                  etiqueta: 'Cómo paga',
                  ayuda: ayudaMediosPago(),
                  child: OpcionesMedioPago(
                    elegido: _medio,
                    onElegir: _elegirMedio,
                  ),
                ),
                if (_pagos.isNotEmpty)
                  ListaPagos(pagos: _pagos, onQuitar: _quitarPago),
                Wrap(
                  spacing: espaciado.md,
                  runSpacing: espaciado.md,
                  children: [
                    SizedBox(
                      width: DialogoCobro._anchoMonto,
                      child: TextField(
                        controller: _monto,
                        focusNode: _focoMonto,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => unawaited(_registrar()),
                        decoration: InputDecoration(
                          labelText: 'Recibido ($simbolo)',
                          hintText: 'Vacío = exacto',
                          prefixText: '$simbolo ',
                        ),
                      ),
                    ),
                    if (_medio.conReferencia)
                      SizedBox(
                        width: DialogoCobro._anchoReferencia,
                        child: TextField(
                          controller: _referencia,
                          onSubmitted: (_) => unawaited(_registrar()),
                          decoration: const InputDecoration(
                            labelText: 'Referencia (opcional)',
                          ),
                        ),
                      ),
                  ],
                ),
                PanelCobro(cobro: mostrado, escritoCorto: _escritoCorto),
                BotonesCrear(
                  etiqueta: _escritoCorto
                      ? 'Añadir este pago'
                      : 'Registrar venta',
                  guardando:
                      _registrando || !_escritoCorto && !cobro.puedeRegistrarse,
                  onCrear: () => unawaited(_registrar()),
                ),
                Text(
                  'Alt+1… forma de pago · vacío cobra exacto · Ctrl+M otro '
                  'pago (mixto) · Enter registra · Esc vuelve al ticket',
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
