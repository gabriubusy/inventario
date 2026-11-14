import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/recepcion.dart';
import 'package:inventario/features/compras/domain/resultados_compra.dart';
import 'package:inventario/features/compras/domain/resumen_pedidos.dart';
import 'package:inventario/features/compras/presentation/aviso_recepcion.dart';
import 'package:inventario/features/compras/presentation/fila_pedido.dart';
import 'package:inventario/features/compras/presentation/filtro_pedidos.dart';
import 'package:inventario/features/compras/presentation/panel_recepcion.dart';
import 'package:inventario/features/inicio/presentation/cifra_del_dia.dart';

const _teclasFiltro = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
];

/// Ctrl+P: every order placed to a supplier and what really arrived of
/// each one. The goods enter the stock here, not when ordering.
class PantallaPedidos extends StatefulWidget {
  const PantallaPedidos({
    super.key,
    required this.compras,
    this.aBolivares,
    this.onNuevoPedido,
    this.onCuentas,
  });

  static const _anchoMaximo = 1240.0;

  final ControladorCompras compras;
  final int? Function(int)? aBolivares;

  /// F2, the same window as on the home screen; hidden when null.
  final VoidCallback? onNuevoPedido;

  /// F10, the invoice in Cuentas por pagar; hidden when null.
  final VoidCallback? onCuentas;

  @override
  State<PantallaPedidos> createState() => _PantallaPedidosState();
}

class _PantallaPedidosState extends State<PantallaPedidos> {
  final _busqueda = TextEditingController();
  final _focoBusqueda = FocusNode();
  final _panel = GlobalKey<PanelRecepcionState>();
  var _filtro = FiltroPedidos.pendientes;
  String? _elegidoId;
  var _recibiendo = false;
  var _guardando = false;

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

  List<Compra> get _visibles {
    final buscado = normalizarParaBusqueda(_busqueda.text);
    return [
      for (final compra in widget.compras.compras)
        if (_filtro.acepta(compra) &&
            (buscado.isEmpty ||
                normalizarParaBusqueda(compra.proveedor).contains(buscado) ||
                normalizarParaBusqueda(compra.factura).contains(buscado) ||
                compra.lineas.any(
                  (l) => normalizarParaBusqueda(l.producto).contains(buscado),
                )))
          compra,
    ];
  }

  Compra? get _elegido {
    final visibles = _visibles;
    if (visibles.isEmpty) return null;
    return visibles.firstWhere(
      (c) => c.id == _elegidoId,
      orElse: () => visibles.first,
    );
  }

  void _mover(int pasos) {
    if (_recibiendo) return;
    final visibles = _visibles;
    final actual = _elegido;
    if (actual == null) return;
    final destino = (visibles.indexOf(actual) + pasos).clamp(
      0,
      visibles.length - 1,
    );
    setState(() => _elegidoId = visibles[destino].id);
  }

  void _filtrar(FiltroPedidos filtro) => setState(() => _filtro = filtro);

  void _recibir() {
    final elegido = _elegido;
    if (elegido == null || !elegido.estado.esperando) return;
    setState(() {
      _elegidoId = elegido.id;
      _recibiendo = true;
    });
  }

  Future<void> _guardar(List<Llegada> llegadas, String nota) async {
    final elegido = _elegido;
    if (elegido == null || _guardando) return;
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final resultado = await widget.compras.recibir(
      elegido.id,
      llegadas,
      nota: nota,
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    switch (resultado) {
      case RecepcionRegistrada(:final compra, :final lineas):
        setState(() => _recibiendo = false);
        mostrarRecepcionRegistrada(
          mensajero,
          widget.compras,
          compra,
          lineas: lineas,
        );
      case RecepcionVacia():
        _avisar(mensajero, 'Escribe lo que llegó de al menos una línea');
      case RecepcionSinProducto(:final producto):
        _avisar(mensajero, '$producto ya no existe: no se puede recibir');
    }
  }

  void _avisar(ScaffoldMessengerState mensajero, String texto) => mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));

  void _volver() {
    if (_recibiendo) {
      setState(() => _recibiendo = false);
      return;
    }
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
    for (final (i, tecla) in _teclasFiltro.indexed)
      SingleActivator(tecla, alt: true): () =>
          _filtrar(FiltroPedidos.values[i]),
    if (_recibiendo) ...{
      const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
          _panel.currentState?.guardar(),
      const SingleActivator(LogicalKeyboardKey.keyT, alt: true): () =>
          _panel.currentState?.llegoTodo(),
    } else
      const SingleActivator(LogicalKeyboardKey.enter): _recibir,
    const SingleActivator(LogicalKeyboardKey.f2): ?widget.onNuevoPedido,
    const SingleActivator(LogicalKeyboardKey.f10): ?widget.onCuentas,
  };

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return AtajosDeTeclado(
      atajos: _atajos,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pedidos a proveedores'),
          actions: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _busqueda,
                focusNode: _focoBusqueda,
                decoration: const InputDecoration(
                  hintText: 'Proveedor, factura o producto (Ctrl+K)',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(width: espaciado.md),
            if (widget.onNuevoPedido case final nuevo?)
              FilledButton(
                onPressed: nuevo,
                child: Row(
                  spacing: espaciado.sm,
                  children: [
                    const Text('Nuevo pedido'),
                    TeclaAtajo(
                      'F2',
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ],
                ),
              ),
            SizedBox(width: espaciado.xl),
          ],
        ),
        body: ListenableBuilder(
          listenable: widget.compras,
          builder: (context, _) => Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: PantallaPedidos._anchoMaximo,
              ),
              child: Padding(
                padding: EdgeInsets.all(espaciado.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: espaciado.md,
                  children: [
                    _Cifras(
                      resumen: widget.compras.resumenPedidos,
                      hoy: widget.compras.hoy,
                      aBolivares: widget.aBolivares,
                    ),
                    _Filtros(elegido: _filtro, onElegir: _filtrar),
                    Expanded(
                      flex: 3,
                      child: _Tabla(
                        visibles: _visibles,
                        elegido: _elegido,
                        hoy: widget.compras.hoy,
                        filtro: _filtro,
                        onElegir: (compra) =>
                            setState(() => _elegidoId = compra.id),
                        onRecibir: _recibir,
                      ),
                    ),
                    if (_elegido case final elegido? when _recibiendo)
                      Expanded(
                        flex: 4,
                        child: PanelRecepcion(
                          key: _panel,
                          compra: elegido,
                          guardando: _guardando,
                          onGuardar: (llegadas, nota) =>
                              unawaited(_guardar(llegadas, nota)),
                          onCerrar: () => setState(() => _recibiendo = false),
                        ),
                      )
                    else
                      _Acciones(
                        puedeRecibir: _elegido?.estado.esperando ?? false,
                        onRecibir: _recibir,
                        onCuentas: widget.onCuentas,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Cifras extends StatelessWidget {
  const _Cifras({
    required this.resumen,
    required this.hoy,
    required this.aBolivares,
  });

  final ResumenPedidos resumen;
  final DateTime hoy;
  final int? Function(int)? aBolivares;

  @override
  Widget build(BuildContext context) {
    final alertas = context.coloresEstado;
    final enBs = aBolivares?.call(resumen.porRecibir);
    final viejo = resumen.masViejo;
    final diferencia = resumen.diferenciaMes;
    return Row(
      spacing: context.espaciado.md,
      children: [
        Expanded(
          child: CifraDelDia(
            titulo: 'Pedidos por recibir',
            valor: '${resumen.pendientes}',
            detalle: viejo == null
                ? 'Todo recibido'
                : 'el más viejo del ${formatearFechaCorta(viejo, hoy)}',
            color: resumen.pendientes > 0 ? alertas.textoBajo : null,
          ),
        ),
        Expanded(
          child: CifraDelDia(
            titulo: 'Valor por recibir',
            valor: formatearDolares(resumen.porRecibir),
            detalle: enBs == null
                ? 'Sin tasa de hoy'
                : '${formatearBolivares(enBs)} a la tasa de hoy',
          ),
        ),
        Expanded(
          child: CifraDelDia(
            titulo: 'Recibidos esta semana',
            valor: '${resumen.recibidos}',
            detalle: resumen.conDiferencias == 0
                ? 'todos como se pidieron'
                : '${resumen.conDiferencias} con diferencias',
          ),
        ),
        Expanded(
          child: CifraDelDia(
            titulo: 'Diferencias del mes',
            valor: diferencia == 0
                ? 'Cuadra'
                : '${diferencia > 0 ? '+' : '−'}'
                      '${formatearDolares(diferencia.abs())}',
            detalle: diferencia == 0
                ? 'lo pedido fue lo que llegó'
                : diferencia > 0
                ? 'más de lo pedido'
                : 'menos de lo pedido',
            color: diferencia == 0 ? null : alertas.textoBajo,
          ),
        ),
      ],
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({required this.elegido, required this.onElegir});

  final FiltroPedidos elegido;
  final ValueChanged<FiltroPedidos> onElegir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      spacing: context.espaciado.md,
      children: [
        Tooltip(
          message: [
            for (final (i, f) in FiltroPedidos.values.indexed)
              '${f.etiqueta} · Alt+${i + 1}',
          ].join('\n'),
          child: ExcludeFocus(
            child: SegmentedButton<FiltroPedidos>(
              showSelectedIcon: false,
              segments: [
                for (final filtro in FiltroPedidos.values)
                  ButtonSegment(value: filtro, label: Text(filtro.etiqueta)),
              ],
              selected: {elegido},
              onSelectionChanged: (v) => onElegir(v.first),
            ),
          ),
        ),
        const Spacer(),
        Text(
          '↑ ↓ elige · Enter abre la recepción',
          style: tema.textTheme.bodySmall?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Tabla extends StatelessWidget {
  const _Tabla({
    required this.visibles,
    required this.elegido,
    required this.hoy,
    required this.filtro,
    required this.onElegir,
    required this.onRecibir,
  });

  final List<Compra> visibles;
  final Compra? elegido;
  final DateTime hoy;
  final FiltroPedidos filtro;
  final ValueChanged<Compra> onElegir;
  final VoidCallback onRecibir;

  String get _vacio => switch (filtro) {
    FiltroPedidos.pendientes => 'No hay pedidos por recibir',
    FiltroPedidos.parciales => 'Ningún pedido llegó a medias',
    FiltroPedidos.recibidos => 'Aún no se ha recibido ningún pedido',
    FiltroPedidos.todos => 'Todavía no hay pedidos a proveedores',
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(espaciado.md),
            child: ColumnasPedido(
              celdas: [
                for (final (texto, derecha) in const [
                  ('FECHA', false),
                  ('PROVEEDOR', false),
                  ('FACTURA', false),
                  ('LÍNEAS', true),
                  ('TOTAL', true),
                  ('PAGO', false),
                  ('ESTADO', false),
                ])
                  Text(
                    texto,
                    textAlign: derecha ? TextAlign.right : TextAlign.left,
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
                _vacio,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: colores.onSurfaceVariant,
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final compra in visibles)
                    FilaPedido(
                      compra: compra,
                      hoy: hoy,
                      elegida: compra.id == elegido?.id,
                      onElegir: () => onElegir(compra),
                      onRecibir: onRecibir,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Acciones extends StatelessWidget {
  const _Acciones({
    required this.puedeRecibir,
    required this.onRecibir,
    required this.onCuentas,
  });

  final bool puedeRecibir;
  final VoidCallback onRecibir;
  final VoidCallback? onCuentas;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return Row(
      spacing: espaciado.md,
      children: [
        FilledButton(
          onPressed: puedeRecibir ? onRecibir : null,
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          child: Row(
            spacing: espaciado.sm,
            children: [
              const Text('Confirmar lo que llegó'),
              TeclaAtajo('Enter', color: colores.onPrimary),
            ],
          ),
        ),
        if (onCuentas case final cuentas?)
          OutlinedButton(
            onPressed: cuentas,
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
            child: Row(
              spacing: espaciado.sm,
              children: [
                const Text('Ver la factura en Cuentas'),
                TeclaAtajo('F10', color: colores.onSurfaceVariant),
              ],
            ),
          ),
        const Spacer(),
        Text(
          'Lo pedido no toca el stock hasta confirmar la recepción',
          style: tema.textTheme.bodySmall?.copyWith(
            color: colores.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
