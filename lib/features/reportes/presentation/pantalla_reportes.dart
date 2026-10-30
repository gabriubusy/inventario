import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/inicio/presentation/cifra_del_dia.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';
import 'package:inventario/features/reportes/application/construir_reportes.dart';
import 'package:inventario/features/reportes/domain/exportador_reportes.dart';
import 'package:inventario/features/reportes/domain/reporte.dart';
import 'package:inventario/features/reportes/presentation/tabla_reporte.dart';

const _teclasTipo = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
];

/// F12: six reports over a period, printable as PDF and saved as Excel.
class PantallaReportes extends StatefulWidget {
  const PantallaReportes({
    super.key,
    required this.movimientos,
    required this.existencias,
    required this.compras,
    required this.gastos,
    required this.exportador,
  });

  static const _anchoMaximo = 1240.0;

  final ControladorMovimientos movimientos;
  final ControladorExistencias existencias;
  final ControladorCompras compras;
  final ControladorGastos gastos;
  final ExportadorReportes exportador;

  @override
  State<PantallaReportes> createState() => _PantallaReportesState();
}

class _PantallaReportesState extends State<PantallaReportes> {
  var _tipo = TipoReporte.ventas;
  var _periodo = PeriodoReporte.mes;

  DateTime get _hoy => widget.movimientos.hoy;

  Reporte get _reporte => construirReporte(_tipo, _periodo, (
    movimientos: widget.movimientos.todos,
    productos: widget.existencias.productos,
    cuentas: widget.compras.cuentas,
    pagos: widget.compras.pagos,
    gastos: widget.gastos.todos,
  ), _hoy);

  String get _subtitulo =>
      '${_tipo == TipoReporte.inventario ? 'Hoy' : _periodo.etiqueta} · '
      '${formatearFechaLarga(_hoy)}';

  void _siguientePeriodo() => setState(() {
    const valores = PeriodoReporte.values;
    _periodo = valores[(_periodo.index + 1) % valores.length];
  });

  Future<void> _pdf() => widget.exportador.pdf(_reporte, subtitulo: _subtitulo);

  Future<void> _excel() async {
    final mensajero = ScaffoldMessenger.of(context);
    final nombre =
        '${_tipo.etiqueta} ${_hoy.year}-${_hoy.month.toString().padLeft(2, '0')}-${_hoy.day.toString().padLeft(2, '0')}';
    final guardado = await widget.exportador.excel(_reporte, nombre: nombre);
    if (!guardado) return;
    mensajero.showSnackBar(SnackBar(content: Text('Guardado "$nombre.xlsx"')));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return AtajosDeTeclado(
      atajos: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            unawaited(Navigator.of(context).maybePop()),
        const SingleActivator(LogicalKeyboardKey.keyP, alt: true):
            _siguientePeriodo,
        const SingleActivator(LogicalKeyboardKey.keyP, control: true): () =>
            unawaited(_pdf()),
        const SingleActivator(LogicalKeyboardKey.keyE, control: true): () =>
            unawaited(_excel()),
        for (final (i, tecla) in _teclasTipo.indexed)
          SingleActivator(tecla, alt: true): () =>
              setState(() => _tipo = TipoReporte.values[i]),
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reportes'),
          actions: [
            DropdownButton<PeriodoReporte>(
              value: _periodo,
              focusColor: Colors.transparent,
              items: [
                for (final p in PeriodoReporte.values)
                  DropdownMenuItem(value: p, child: Text(p.etiqueta)),
              ],
              onChanged: (p) => p == null ? null : setState(() => _periodo = p),
            ),
            TeclaAtajo('Alt+P', color: colores.onSurfaceVariant),
            SizedBox(width: espaciado.lg),
            for (final (texto, atajo, accion) in [
              ('PDF', 'Ctrl+P', _pdf),
              ('Excel', 'Ctrl+E', _excel),
            ])
              Padding(
                padding: EdgeInsets.only(right: espaciado.sm),
                child: OutlinedButton(
                  onPressed: () => unawaited(accion()),
                  child: Row(
                    spacing: espaciado.sm,
                    children: [
                      Text(texto),
                      TeclaAtajo(atajo, color: colores.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            SizedBox(width: espaciado.lg),
          ],
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([
            widget.movimientos,
            widget.existencias,
            widget.compras,
            widget.gastos,
          ]),
          builder: (context, _) {
            final reporte = _reporte;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: PantallaReportes._anchoMaximo,
                ),
                child: ListView(
                  padding: EdgeInsets.all(espaciado.xl),
                  children: [
                    ConEtiqueta(
                      etiqueta: 'Reporte',
                      ayuda: lineasAyuda(
                        [for (final t in TipoReporte.values) t.etiqueta],
                        [
                          for (var i = 1; i <= TipoReporte.values.length; i++)
                            'Alt+$i',
                        ],
                      ).join('\n'),
                      child: ExcludeFocus(
                        child: Wrap(
                          spacing: espaciado.sm,
                          runSpacing: espaciado.sm,
                          children: [
                            for (final t in TipoReporte.values)
                              ChoiceChip(
                                label: Text(t.etiqueta),
                                selected: t == _tipo,
                                showCheckmark: false,
                                onSelected: (_) => setState(() => _tipo = t),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: espaciado.md),
                    Text(
                      _subtitulo,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: espaciado.md),
                    Row(
                      spacing: espaciado.md,
                      children: [
                        for (final c in reporte.cifras)
                          Expanded(
                            child: CifraDelDia(
                              titulo: c.titulo,
                              valor: c.valor,
                              detalle: c.detalle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: espaciado.lg),
                    TablaReporte(reporte: reporte),
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
