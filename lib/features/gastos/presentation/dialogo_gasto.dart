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
import 'package:inventario/core/textos_dinero.dart';
import 'package:inventario/features/compras/domain/cuenta_por_pagar.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/gastos/domain/categoria_gasto.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';

const _teclasCategoria = [
  LogicalKeyboardKey.keyA,
  LogicalKeyboardKey.keyS,
  LogicalKeyboardKey.keyD,
  LogicalKeyboardKey.keyF,
  LogicalKeyboardKey.keyG,
  LogicalKeyboardKey.keyH,
  LogicalKeyboardKey.keyJ,
];
const _letras = ['A', 'S', 'D', 'F', 'G', 'H', 'J'];
const _teclasMedio = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
];

/// Ctrl+G from home or the till.
Future<void> mostrarDialogoGasto(
  BuildContext context, {
  required ControladorGastos gastos,
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoGasto(gastos: gastos),
);

/// An expense or other income: kind, category, amount, how it was paid.
class DialogoGasto extends StatefulWidget {
  const DialogoGasto({super.key, required this.gastos});

  static const _ancho = 600.0;

  final ControladorGastos gastos;

  @override
  State<DialogoGasto> createState() => _DialogoGastoState();
}

class _DialogoGastoState extends State<DialogoGasto> {
  final _monto = TextEditingController();
  final _nota = TextEditingController();
  var _ingreso = false;
  var _categoria = CategoriaGasto.servicios;
  var _medio = MedioPago.efectivoBolivares;
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
    _nota.dispose();
    super.dispose();
  }

  List<CategoriaGasto> get _categorias => CategoriaGasto.de(ingreso: _ingreso);

  void _elegirTipo(bool ingreso) => setState(() {
    _ingreso = ingreso;
    _categoria = _categorias.first;
  });

  int? get _entregado => parseDecimal(_monto.text, decimales: decimalesDinero);

  /// "= $ 2,03 a tasa de hoy" for an amount in bolívares.
  String? get _equivale {
    final entregado = _entregado;
    if (entregado == null || _medio.moneda == Moneda.dolares) return null;
    final dolares = aDolares(
      entregado,
      Moneda.bolivares,
      widget.gastos.tasaDeHoy,
    );
    return dolares == null
        ? 'Sin tasa de hoy'
        : '= ${formatearDolares(dolares)} a tasa de hoy';
  }

  Future<void> _registrar() async {
    final monto = _entregado;
    if (monto == null || monto <= 0) {
      setState(() => _error = 'Escribe el monto');
      return;
    }
    if (_guardando) return;
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final gasto = await widget.gastos.registrar(
      categoria: _categoria,
      medio: _medio,
      monto: monto,
      nota: _nota.text.trim(),
    );
    if (!mounted) return;
    navegador.pop();
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${gasto.esIngreso ? 'Ingreso' : 'Gasto'} registrado · '
            '${gasto.categoria.etiqueta} · '
            '${textoEnMoneda(gasto.monto, gasto.medio.moneda)}',
          ),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () => unawaited(widget.gastos.deshacer()),
          ),
        ),
      );
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    const SingleActivator(LogicalKeyboardKey.keyQ, alt: true): () =>
        _elegirTipo(false),
    const SingleActivator(LogicalKeyboardKey.keyW, alt: true): () =>
        _elegirTipo(true),
    for (final (i, tecla) in _teclasCategoria.indexed)
      SingleActivator(tecla, alt: true): () {
        if (i < _categorias.length) setState(() => _categoria = _categorias[i]);
      },
    for (final (i, tecla) in _teclasMedio.indexed)
      SingleActivator(tecla, alt: true): () {
        if (i < MedioPago.values.length) {
          setState(() => _medio = MedioPago.values[i]);
        }
      },
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final equivale = _equivale;
    final error = _error;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: _atajos,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DialogoGasto._ancho),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(espaciado.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: espaciado.lg,
              children: [
                const EncabezadoDialogo(
                  titulo: 'Gasto o ingreso',
                  icono: Icons.receipt_outlined,
                ),
                ExcludeFocus(
                  child: Row(
                    spacing: espaciado.sm,
                    children: [
                      Expanded(
                        child: OpcionSeleccionable(
                          titulo: 'Gasto',
                          detalle: 'Sale dinero · Alt+Q',
                          elegida: !_ingreso,
                          onPulsar: () => _elegirTipo(false),
                        ),
                      ),
                      Expanded(
                        child: OpcionSeleccionable(
                          titulo: 'Ingreso',
                          detalle: 'Entra dinero que no es venta · Alt+W',
                          elegida: _ingreso,
                          onPulsar: () => _elegirTipo(true),
                        ),
                      ),
                    ],
                  ),
                ),
                ConEtiqueta(
                  etiqueta: 'Categoría',
                  child: ExcludeFocus(
                    child: Wrap(
                      spacing: espaciado.sm,
                      runSpacing: espaciado.sm,
                      children: [
                        for (final (i, c) in _categorias.indexed)
                          ChoiceChip(
                            label: Text('${c.etiqueta} · Alt+${_letras[i]}'),
                            selected: c == _categoria,
                            showCheckmark: false,
                            onSelected: (_) => setState(() => _categoria = c),
                          ),
                      ],
                    ),
                  ),
                ),
                ConEtiqueta(
                  etiqueta: _ingreso ? 'Cómo entró' : 'Cómo se pagó',
                  child: ExcludeFocus(
                    child: Wrap(
                      spacing: espaciado.sm,
                      runSpacing: espaciado.sm,
                      children: [
                        for (final (i, m) in MedioPago.values.indexed)
                          ChoiceChip(
                            label: Text('${m.etiqueta} · Alt+${i + 1}'),
                            selected: m == _medio,
                            showCheckmark: false,
                            onSelected: (_) => setState(() => _medio = m),
                          ),
                      ],
                    ),
                  ),
                ),
                TextField(
                  controller: _monto,
                  autofocus: true,
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText:
                        'Monto en ${_medio.moneda == Moneda.dolares ? r'$' : 'Bs'}',
                    helperText: equivale,
                  ),
                ),
                TextField(
                  controller: _nota,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Qué fue (opcional)',
                    hintText: 'Hielo para la nevera…',
                  ),
                  onSubmitted: (_) => unawaited(_registrar()),
                ),
                if (error != null)
                  Text(
                    error,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: colores.error,
                    ),
                  ),
                BotonesCrear(
                  etiqueta: _ingreso ? 'Registrar ingreso' : 'Registrar gasto',
                  guardando: _guardando,
                  onCrear: () => unawaited(_registrar()),
                ),
                Text(
                  'Alt+Q gasto · Alt+W ingreso · Alt+A… categoría · '
                  'Alt+1–6 cómo se pagó · Enter registra · Esc cierra',
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
