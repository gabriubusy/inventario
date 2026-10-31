import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/entradas/presentation/buscador_producto_entrada.dart';
import 'package:inventario/features/kardex/domain/filtro_kardex.dart';
import 'package:inventario/features/kardex/domain/linea_kardex.dart';
import 'package:inventario/features/kardex/domain/resumen_kardex.dart';
import 'package:inventario/features/kardex/presentation/filtros_kardex.dart';
import 'package:inventario/features/kardex/presentation/resumen_kardex_tarjetas.dart';
import 'package:inventario/features/kardex/presentation/tabla_kardex.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/producto.dart';

const _teclasGrupo = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
];

/// F8: every movement of one product with the balance after each.
/// Without [productoId] it starts on the product search.
class PantallaKardex extends StatefulWidget {
  const PantallaKardex({
    super.key,
    required this.movimientos,
    required this.existencias,
    this.productoId,
  });

  static const _anchoMaximo = 1240.0;

  final ControladorMovimientos movimientos;
  final ControladorExistencias existencias;
  final String? productoId;

  @override
  State<PantallaKardex> createState() => _PantallaKardexState();
}

class _PantallaKardexState extends State<PantallaKardex> {
  final _busqueda = TextEditingController();
  final _focoBusqueda = FocusNode();
  late String? _productoId = widget.productoId;
  GrupoMovimiento? _grupo;
  var _periodo = PeriodoKardex.semana;
  String? _marca;

  @override
  void dispose() {
    _busqueda.dispose();
    _focoBusqueda.dispose();
    super.dispose();
  }

  Producto? get _producto {
    for (final p in widget.existencias.productos) {
      if (p.id == _productoId) return p;
    }
    return null;
  }

  void _elegir(Producto producto) => setState(() {
    _productoId = producto.id;
    _marca = null;
  });

  void _buscarOtro() {
    setState(() => _productoId = null);
    _busqueda.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focoBusqueda.requestFocus();
    });
  }

  void _siguientePeriodo() => setState(() {
    const valores = PeriodoKardex.values;
    _periodo = valores[(_periodo.index + 1) % valores.length];
  });

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    const SingleActivator(LogicalKeyboardKey.escape): () =>
        unawaited(Navigator.of(context).maybePop()),
    const SingleActivator(LogicalKeyboardKey.keyK, control: true): _buscarOtro,
    const SingleActivator(LogicalKeyboardKey.keyP, alt: true):
        _siguientePeriodo,
    for (final (i, tecla) in _teclasGrupo.indexed)
      SingleActivator(tecla, alt: true): () => setState(
        () => _grupo = FiltrosKardex.etiquetasGrupo.keys.elementAt(i),
      ),
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
          title: Text(switch (_producto) {
            final p? => 'Kardex · ${p.nombre}',
            null => 'Kardex',
          }),
          actions: [
            TextButton(
              onPressed: _buscarOtro,
              child: Row(
                spacing: espaciado.sm,
                children: [
                  const Text('Otro producto'),
                  TeclaAtajo('Ctrl+K', color: colores.onSurfaceVariant),
                ],
              ),
            ),
            SizedBox(width: espaciado.lg),
          ],
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([
            widget.movimientos,
            widget.existencias,
          ]),
          builder: (context, _) => Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: PantallaKardex._anchoMaximo,
              ),
              child: switch (_producto) {
                final producto? => _Kardex(
                  producto: producto,
                  movimientos: widget.movimientos,
                  grupo: _grupo,
                  periodo: _periodo,
                  marca: _marca,
                  onGrupo: (g) => setState(() => _grupo = g),
                  onPeriodo: (p) => setState(() => _periodo = p),
                  onMarca: (m) => setState(() => _marca = m),
                ),
                null => Padding(
                  padding: EdgeInsets.all(espaciado.xl),
                  child: BuscadorProductoEntrada(
                    productos: widget.existencias.productos,
                    controller: _busqueda,
                    focusNode: _focoBusqueda,
                    onElegir: _elegir,
                    validator: (_) => null,
                  ),
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Kardex extends StatelessWidget {
  const _Kardex({
    required this.producto,
    required this.movimientos,
    required this.grupo,
    required this.periodo,
    required this.marca,
    required this.onGrupo,
    required this.onPeriodo,
    required this.onMarca,
  });

  final Producto producto;
  final ControladorMovimientos movimientos;
  final GrupoMovimiento? grupo;
  final PeriodoKardex periodo;
  final String? marca;
  final ValueChanged<GrupoMovimiento?> onGrupo;
  final ValueChanged<PeriodoKardex> onPeriodo;
  final ValueChanged<String?> onMarca;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final hoy = movimientos.hoy;
    final marca = this.marca;
    // With one brand chosen, the balance follows that lot alone.
    final stock = marca == null
        ? producto.cantidad
        : producto.lotes
              .where((l) => esDeMarca(l.marca, marca))
              .fold(0, (total, l) => total + l.cantidad);
    final propios = [
      for (final m in movimientos.todos)
        if (m.productoId == producto.id &&
            (marca == null || esDeMarca(m.marca, marca)))
          m,
    ];
    final todas = lineasKardex(propios, stock);
    final delPeriodo = filtrarKardex(todas, periodo: periodo, hoy: hoy);
    final visibles = filtrarKardex(
      todas,
      grupo: grupo,
      periodo: periodo,
      hoy: hoy,
    );
    return ListView(
      padding: EdgeInsets.all(espaciado.xl),
      children: [
        ResumenKardexTarjetas(
          producto: producto,
          resumen: ResumenKardex.de(delPeriodo),
          periodo: periodo.etiqueta.toLowerCase(),
        ),
        SizedBox(height: espaciado.lg),
        FiltrosKardex(
          grupo: grupo,
          periodo: periodo,
          // One brand can come from two suppliers; the filter lists it once.
          marcas: {for (final l in producto.lotes) l.marca}.toList(),
          marca: marca,
          onGrupo: onGrupo,
          onPeriodo: onPeriodo,
          onMarca: onMarca,
        ),
        SizedBox(height: espaciado.md),
        TablaKardex(lineas: visibles, unidad: producto.forma.unidad, hoy: hoy),
      ],
    );
  }
}
