import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/productos/application/controlador_ajuste_precios.dart';
import 'package:inventario/features/productos/domain/ambito_ajuste.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/presentation/campo_cantidad.dart';
import 'package:inventario/features/productos/presentation/opcion_seleccionable.dart';
import 'package:inventario/features/productos/presentation/opciones_ambito_ajuste.dart';
import 'package:inventario/features/productos/presentation/previsto_ajuste.dart';

const _teclasLista = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
];

/// How many products changed, or null when closed without applying.
Future<int?> mostrarDialogoAjustePrecios(
  BuildContext context, {
  required ControladorAjustePrecios ajuste,
  List<String> proveedores = const [],
}) => showDialog<int>(
  context: context,
  builder: (_) =>
      DialogoAjustePrecios(ajuste: ajuste, proveedores: proveedores),
);

/// Raises or lowers one price list by a percentage over many products.
class DialogoAjustePrecios extends StatefulWidget {
  const DialogoAjustePrecios({
    super.key,
    required this.ajuste,
    this.proveedores = const [],
  });

  static const _ancho = 620.0;

  final ControladorAjustePrecios ajuste;
  final List<String> proveedores;

  @override
  State<DialogoAjustePrecios> createState() => _DialogoAjustePreciosState();
}

class _DialogoAjustePreciosState extends State<DialogoAjustePrecios> {
  final _porcentaje = TextEditingController();
  var _baja = false;
  var _lista = ListaPrecio.detal;
  AmbitoAjuste _ambito = const TodosLosProductos();
  var _aplicando = false;

  @override
  void initState() {
    super.initState();
    _porcentaje.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _porcentaje.dispose();
    super.dispose();
  }

  /// Hundredths of a percent, negative when lowering.
  int get _cambio {
    final valor = parseDecimal(_porcentaje.text, decimales: decimalesDinero);
    return (valor ?? 0) * (_baja ? -1 : 1);
  }

  /// Pressed again, the same key moves to the next category.
  void _porCategoria() => setState(
    () => _ambito = switch (_ambito) {
      DeCategoria(:final categoria) => DeCategoria(
        Categoria.values[(categoria.index + 1) % Categoria.values.length],
      ),
      _ => DeCategoria(Categoria.values.first),
    },
  );

  void _porProveedor() {
    final nombres = widget.proveedores;
    if (nombres.isEmpty) return;
    setState(
      () => _ambito = switch (_ambito) {
        DeProveedor(:final proveedor) => DeProveedor(
          nombres[(nombres.indexOf(proveedor) + 1) % nombres.length],
        ),
        _ => DeProveedor(nombres.first),
      },
    );
  }

  Future<void> _aplicar() async {
    if (_aplicando || _cambio == 0) return;
    setState(() => _aplicando = true);
    final navegador = Navigator.of(context);
    final cuantos = await widget.ajuste.aplicar(_ambito, _lista, _cambio);
    if (!mounted) return;
    navegador.pop(cuantos);
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    const SingleActivator(LogicalKeyboardKey.keyQ, alt: true): () =>
        setState(() => _baja = false),
    const SingleActivator(LogicalKeyboardKey.keyW, alt: true): () =>
        setState(() => _baja = true),
    for (final (i, lista) in ListaPrecio.values.indexed)
      SingleActivator(_teclasLista[i], alt: true): () =>
          setState(() => _lista = lista),
    const SingleActivator(LogicalKeyboardKey.keyA, alt: true): () =>
        setState(() => _ambito = const TodosLosProductos()),
    const SingleActivator(LogicalKeyboardKey.keyS, alt: true): _porCategoria,
    const SingleActivator(LogicalKeyboardKey.keyD, alt: true): _porProveedor,
    const SingleActivator(LogicalKeyboardKey.enter, control: true): () =>
        unawaited(_aplicar()),
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: _atajos,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: DialogoAjustePrecios._ancho,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(espaciado.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: espaciado.lg,
              children: [
                const EncabezadoDialogo(
                  titulo: 'Ajustar precios',
                  icono: Icons.percent,
                ),
                ExcludeFocus(
                  child: Row(
                    spacing: espaciado.sm,
                    children: [
                      Expanded(
                        child: OpcionSeleccionable(
                          titulo: 'Subir',
                          detalle: 'Alt+Q',
                          elegida: !_baja,
                          onPulsar: () => setState(() => _baja = false),
                        ),
                      ),
                      Expanded(
                        child: OpcionSeleccionable(
                          titulo: 'Bajar',
                          detalle: 'Alt+W',
                          elegida: _baja,
                          onPulsar: () => setState(() => _baja = true),
                        ),
                      ),
                    ],
                  ),
                ),
                CampoCantidad(
                  etiqueta: 'Cuánto',
                  controller: _porcentaje,
                  decimales: decimalesDinero,
                  sufijo: '%',
                  autofocus: true,
                  onSubmitted: () => unawaited(_aplicar()),
                ),
                OpcionesAmbitoAjuste(
                  lista: _lista,
                  ambito: _ambito,
                  proveedores: widget.proveedores,
                  onLista: (lista) => setState(() => _lista = lista),
                  onAmbito: (ambito) => setState(() => _ambito = ambito),
                ),
                PrevistoAjuste(
                  cambios: widget.ajuste.previsto(_ambito, _lista, _cambio),
                  lista: _lista,
                ),
                BotonesCrear(
                  etiqueta: 'Aplicar',
                  atajo: 'Ctrl+Enter',
                  guardando: _aplicando,
                  onCrear: () => unawaited(_aplicar()),
                ),
                Text(
                  'Alt+Q sube · Alt+W baja · Alt+1–3 lista · Alt+A todo · '
                  'Alt+S categoría · Alt+D proveedor · Esc cierra',
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
