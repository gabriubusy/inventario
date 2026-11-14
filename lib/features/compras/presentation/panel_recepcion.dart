import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/recepcion.dart';
import 'package:inventario/features/compras/domain/resumen_recepcion.dart';
import 'package:inventario/features/compras/presentation/fila_recepcion.dart';
import 'package:inventario/features/compras/presentation/resumen_de_recepcion.dart';
import 'package:inventario/features/entradas/presentation/campo_cantidad_recibida.dart';
import 'package:inventario/features/entradas/presentation/controlador_cantidad.dart';

/// Confirming what arrived, on the same screen as the orders. Each
/// waiting line comes filled with what was ordered: with everything as
/// asked it is just Ctrl+S, and what is left empty keeps waiting.
class PanelRecepcion extends StatefulWidget {
  const PanelRecepcion({
    super.key,
    required this.compra,
    required this.guardando,
    required this.onGuardar,
    required this.onCerrar,
  });

  static const anchoResumen = 320.0;

  final Compra compra;
  final bool guardando;
  final void Function(List<Llegada> llegadas, String nota) onGuardar;
  final VoidCallback onCerrar;

  @override
  State<PanelRecepcion> createState() => PanelRecepcionState();
}

class PanelRecepcionState extends State<PanelRecepcion> {
  final _formulario = GlobalKey<FormState>();
  final _nota = TextEditingController();
  final _piezas = <int, TextEditingController>{};
  final _cantidades = <int, ControladorCantidad>{};
  final _focosPiezas = <int, FocusNode>{};
  final _focosCantidad = <int, FocusNode>{};

  @override
  void initState() {
    super.initState();
    for (final i in _esperando) {
      _piezas[i] = TextEditingController()..addListener(_refrescar);
      _cantidades[i] = ControladorCantidad()..addListener(_refrescar);
      _focosPiezas[i] = FocusNode();
      _focosCantidad[i] = FocusNode();
    }
    llegoTodo();
    final primero = _esperando.firstOrNull;
    if (primero != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        (widget.compra.lineas[primero].forma.cuentaPiezas
                ? _focosPiezas[primero]
                : _focosCantidad[primero])
            ?.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _nota.dispose();
    for (final c in [..._piezas.values, ..._cantidades.values]) {
      c.dispose();
    }
    for (final f in [..._focosPiezas.values, ..._focosCantidad.values]) {
      f.dispose();
    }
    super.dispose();
  }

  void _refrescar() => setState(() {});

  List<int> get _esperando => [
    for (final (i, linea) in widget.compra.lineas.indexed)
      if (!linea.recibida) i,
  ];

  /// Alt+T: the supplier brought exactly what the invoice says.
  void llegoTodo() {
    for (final i in _esperando) {
      final linea = widget.compra.lineas[i];
      _piezas[i]?.text = linea.forma.cuentaPiezas
          ? formatDecimal(linea.piezas, decimales: 0)
          : '';
      _cantidades[i]?.text = formatDecimal(
        linea.cantidad,
        decimales: linea.forma.unidad.decimales,
      );
    }
  }

  List<Llegada> get llegadas => [
    for (final i in _esperando)
      (
        indice: i,
        piezas: CampoCantidadRecibida.leer(_piezas[i]!, 0),
        cantidad: CampoCantidadRecibida.leer(
          _cantidades[i]!,
          widget.compra.lineas[i].forma.unidad.decimales,
          unidad: widget.compra.lineas[i].forma.unidad,
        ),
      ),
  ];

  void guardar() {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    widget.onGuardar(llegadas, _nota.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final compra = widget.compra;
    final resumen = ResumenRecepcion.de(compra, llegadas);
    final factura = compra.factura.isEmpty
        ? 'sin factura'
        : 'factura ${compra.factura}';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surface,
        border: Border.all(color: colores.primary),
        borderRadius: BorderRadius.circular(espaciado.sm + 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(espaciado.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: espaciado.xl,
          children: [
            Expanded(
              child: Form(
                key: _formulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: espaciado.md,
                  children: [
                    Row(
                      spacing: espaciado.md,
                      children: [
                        Expanded(
                          child: Text(
                            'Qué llegó de ${compra.proveedor} · $factura',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tema.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ExcludeFocus(
                          child: OutlinedButton(
                            onPressed: llegoTodo,
                            child: Row(
                              spacing: espaciado.sm,
                              children: [
                                const Text('Llegó todo'),
                                TeclaAtajo(
                                  'Alt+T',
                                  color: colores.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ExcludeFocus(
                          child: IconButton(
                            tooltip: 'Cerrar el panel (Esc)',
                            icon: const Icon(Icons.close),
                            onPressed: widget.onCerrar,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          for (final (i, linea) in compra.lineas.indexed)
                            if (linea.recibida)
                              _YaRecibida(indice: i, compra: compra)
                            else
                              FilaRecepcion(
                                linea: linea,
                                piezas: _piezas[i]!,
                                cantidad: _cantidades[i]!,
                                focoPiezas: _focosPiezas[i]!,
                                focoCantidad: _focosCantidad[i]!,
                              ),
                        ],
                      ),
                    ),
                    TextField(
                      controller: _nota,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Nota (opcional)',
                        hintText: 'El resto llega el jueves',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: PanelRecepcion.anchoResumen,
              child: ResumenDeRecepcion(
                resumen: resumen,
                total: compra.lineas.length,
                guardando: widget.guardando,
                onGuardar: guardar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A line confirmed in an earlier reception; it is not asked again.
class _YaRecibida extends StatelessWidget {
  const _YaRecibida({required this.indice, required this.compra});

  final int indice;
  final Compra compra;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final linea = compra.lineas[indice];
    final llegada = [
      if (linea.piezasLlegadas > 0) '${linea.piezasLlegadas} pz',
      linea.forma.unidad.formatear(linea.cantidadLlegada),
    ].join(' · ');
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.espaciado.sm),
      child: Row(
        spacing: context.espaciado.md,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '${linea.producto} · ${linea.marca}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: colores.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Text(
              'Ya recibido · $llegada',
              textAlign: TextAlign.right,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: colores.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
