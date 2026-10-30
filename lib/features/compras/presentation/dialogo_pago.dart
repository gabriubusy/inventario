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
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/domain/cuenta_por_pagar.dart';
import 'package:inventario/features/compras/domain/resultados_compra.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';

const _teclasMedio = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
];

Future<void> mostrarDialogoPago(
  BuildContext context, {
  required ControladorCompras compras,
  required CuentaPorPagar cuenta,
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoPago(compras: compras, cuenta: cuenta),
);

/// Pays all or part of an invoice, in dollars or bolívares.
class DialogoPago extends StatefulWidget {
  const DialogoPago({super.key, required this.compras, required this.cuenta});

  static const _ancho = 600.0;

  final ControladorCompras compras;
  final CuentaPorPagar cuenta;

  @override
  State<DialogoPago> createState() => _DialogoPagoState();
}

class _DialogoPagoState extends State<DialogoPago> {
  final _monto = TextEditingController();
  final _referencia = TextEditingController();
  final _focoMonto = FocusNode();
  var _medio = MedioPago.efectivoDolares;
  String? _error;
  var _guardando = false;

  @override
  void initState() {
    super.initState();
    _monto.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _monto.dispose();
    _referencia.dispose();
    _focoMonto.dispose();
    super.dispose();
  }

  int? get _tasa => widget.compras.tasaDeHoy;

  String get _simbolo => _medio.moneda == Moneda.dolares ? r'$' : 'Bs';

  int? get _entregado => parseDecimal(_monto.text, decimales: decimalesDinero);

  /// What the typed amount covers in dollars; null while not valid.
  int? get _cubre {
    final entregado = _entregado;
    return entregado == null ? null : aDolares(entregado, _medio.moneda, _tasa);
  }

  void _elegirMedio(MedioPago medio) {
    setState(() {
      _medio = medio;
      _monto.clear();
    });
    _focoMonto.requestFocus();
  }

  /// Fills in the whole debt in the chosen currency.
  void _pagarTodo() {
    final debe = enMoneda(widget.cuenta.debe, _medio.moneda, _tasa);
    if (debe == null) return;
    _monto.text = formatDecimal(
      debe,
      decimales: decimalesDinero,
      minDecimales: decimalesDinero,
    );
  }

  String get _queda {
    final cubre = _cubre;
    final debe = widget.cuenta.debe;
    if (cubre == null || cubre <= 0) {
      return 'Debe ${formatearDolares(debe)}';
    }
    final resto = debe - cubre;
    if (resto < -1) return 'Es más de lo que se debe';
    if (resto <= 0) return 'Pago completo: la factura queda pagada';
    return 'Abono de ${formatearDolares(cubre)} · quedará debiendo '
        '${formatearDolares(resto)}';
  }

  Future<void> _registrar() async {
    final entregado = _entregado;
    if (_guardando || entregado == null || entregado <= 0) {
      setState(() => _error = 'Escribe cuánto se paga');
      return;
    }
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final resultado = await widget.compras.pagar(
      widget.cuenta,
      medio: _medio,
      entregado: entregado,
      referencia: _referencia.text.trim(),
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    switch (resultado) {
      case PagoRegistrado(:final pago, :final debe):
        navegador.pop();
        mensajero
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Pago de ${formatearDolares(pago.monto)} a '
                '${widget.cuenta.compra.proveedor} · '
                '${debe <= 0 ? 'factura pagada' : 'debe ${formatearDolares(debe)}'}',
              ),
              action: SnackBarAction(
                label: 'Deshacer',
                onPressed: () => unawaited(widget.compras.deshacerPago()),
              ),
            ),
          );
      case PagoExcede(:final debe):
        setState(() => _error = 'Solo se deben ${formatearDolares(debe)}');
      case PagoSinTasa():
        setState(
          () => _error = 'Sin la tasa de hoy no se puede pagar en bolívares',
        );
    }
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    for (final (i, tecla) in _teclasMedio.indexed)
      SingleActivator(tecla, alt: true): () =>
          _elegirMedio(MedioPago.paraProveedores[i]),
    const SingleActivator(LogicalKeyboardKey.keyT, alt: true): _pagarTodo,
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final cuenta = widget.cuenta;
    final compra = cuenta.compra;
    final cubre = _cubre;
    final otraMoneda = cubre == null || _medio.moneda == Moneda.dolares
        ? null
        : '= ${formatearDolares(cubre)}';
    final error = _error;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: _atajos,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DialogoPago._ancho),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(espaciado.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: espaciado.lg,
              children: [
                EncabezadoDialogo(
                  titulo: 'Pagar a ${compra.proveedor}',
                  icono: Icons.payments_outlined,
                ),
                Text(
                  '${compra.factura.isEmpty ? 'Compra' : 'Factura ${compra.factura}'}'
                  ' · total ${formatearDolares(compra.total)} · abonado '
                  '${formatearDolares(cuenta.abonado)} · debe '
                  '${formatearDolares(cuenta.debe)}',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                ConEtiqueta(
                  etiqueta: 'Cómo se paga',
                  ayuda: lineasAyuda(
                    [for (final m in MedioPago.paraProveedores) m.etiqueta],
                    [
                      for (
                        var i = 1;
                        i <= MedioPago.paraProveedores.length;
                        i++
                      )
                        'Alt+$i',
                    ],
                  ).join('\n'),
                  child: ExcludeFocus(
                    child: Wrap(
                      spacing: espaciado.sm,
                      runSpacing: espaciado.sm,
                      children: [
                        for (final m in MedioPago.paraProveedores)
                          ChoiceChip(
                            label: Text(m.etiqueta),
                            selected: m == _medio,
                            showCheckmark: false,
                            onSelected: (_) => _elegirMedio(m),
                          ),
                      ],
                    ),
                  ),
                ),
                Row(
                  spacing: espaciado.md,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _monto,
                        focusNode: _focoMonto,
                        autofocus: true,
                        textAlign: TextAlign.right,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Monto en $_simbolo',
                        ),
                        onSubmitted: (_) => unawaited(_registrar()),
                      ),
                    ),
                    if (otraMoneda != null)
                      Text(otraMoneda, style: tema.textTheme.bodyMedium),
                  ],
                ),
                TextField(
                  controller: _referencia,
                  decoration: const InputDecoration(
                    labelText: 'Referencia (opcional)',
                    hintText: 'N° de la transferencia o pago móvil',
                  ),
                  onSubmitted: (_) => unawaited(_registrar()),
                ),
                Text(
                  _queda,
                  style: tema.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (error != null)
                  Text(
                    error,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: colores.error,
                    ),
                  ),
                BotonesCrear(
                  etiqueta: 'Registrar pago',
                  guardando: _guardando,
                  onCrear: () => unawaited(_registrar()),
                ),
                Text(
                  'Alt+1–5 cómo se paga · Alt+T pagar todo · Enter registra '
                  '· Esc cierra',
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
    );
  }
}
