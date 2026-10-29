import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/devoluciones_proveedor/application/controlador_devoluciones_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/devolucion_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/resumen_devoluciones_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/presentation/barra_devoluciones_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/presentation/dialogo_devolucion_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/presentation/fila_devolucion_proveedor.dart';
import 'package:inventario/features/inicio/presentation/cifra_del_dia.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';

/// Every return to suppliers (F6, Alt+D), newest first. Alt+R marks the
/// chosen one's goods as brought again.
class PantallaDevolucionesProveedor extends StatefulWidget {
  const PantallaDevolucionesProveedor({
    super.key,
    required this.devoluciones,
    required this.existencias,
    this.proveedores = const [],
    this.aBolivares,
  });

  static const _anchoMaximo = 1240.0;

  final ControladorDevolucionesProveedor devoluciones;
  final ControladorExistencias existencias;
  final List<String> proveedores;
  final int? Function(int)? aBolivares;

  @override
  State<PantallaDevolucionesProveedor> createState() =>
      _PantallaDevolucionesProveedorState();
}

class _PantallaDevolucionesProveedorState
    extends State<PantallaDevolucionesProveedor> {
  String? _elegidaId;

  List<DevolucionProveedor> get _todas => widget.devoluciones.todas;

  DevolucionProveedor? get _elegida {
    final todas = _todas;
    if (todas.isEmpty) return null;
    return todas.firstWhere(
      (d) => d.id == _elegidaId,
      orElse: () => todas.first,
    );
  }

  void _volver() => unawaited(Navigator.of(context).maybePop());

  void _nueva() => unawaited(
    mostrarDialogoDevolucionProveedor(
      context,
      devoluciones: widget.devoluciones,
      existencias: widget.existencias,
      proveedores: widget.proveedores,
      aBolivares: widget.aBolivares,
    ),
  );

  void _mover(int pasos) {
    final actual = _elegida;
    if (actual == null) return;
    final destino = (_todas.indexOf(actual) + pasos).clamp(
      0,
      _todas.length - 1,
    );
    setState(() => _elegidaId = _todas[destino].id);
  }

  void _marcarRepuesta() {
    final elegida = _elegida;
    if (elegida == null) return;
    unawaited(widget.devoluciones.marcarRepuesta(elegida));
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    const SingleActivator(LogicalKeyboardKey.escape): _volver,
    const SingleActivator(LogicalKeyboardKey.keyI, alt: true): _volver,
    const SingleActivator(LogicalKeyboardKey.keyN, control: true): _nueva,
    const SingleActivator(LogicalKeyboardKey.keyD, control: true): _nueva,
    const SingleActivator(LogicalKeyboardKey.arrowUp): () => _mover(-1),
    const SingleActivator(LogicalKeyboardKey.arrowDown): () => _mover(1),
    const SingleActivator(LogicalKeyboardKey.keyR, alt: true): _marcarRepuesta,
  };

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return AtajosDeTeclado(
      atajos: _atajos,
      child: Scaffold(
        body: Column(
          children: [
            BarraDevolucionesProveedor(onVolver: _volver, onNueva: _nueva),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.devoluciones,
                builder: (context, _) => Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: PantallaDevolucionesProveedor._anchoMaximo,
                    ),
                    child: ListView(
                      padding: EdgeInsets.all(espaciado.xl),
                      children: [
                        _Cifras(
                          resumen: ResumenDevolucionesProveedor.de(
                            _todas,
                            widget.devoluciones.hoy,
                          ),
                        ),
                        SizedBox(height: espaciado.xl),
                        _Tabla(
                          devoluciones: widget.devoluciones,
                          elegida: _elegida,
                          onElegir: (d) => setState(() => _elegidaId = d.id),
                        ),
                        SizedBox(height: espaciado.md),
                        Text(
                          '↑ ↓ elegir · Alt+R marca que ya repuso · En '
                          'Cuentas por pagar (F10) la factura muestra lo '
                          'devuelto',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cifras extends StatelessWidget {
  const _Cifras({required this.resumen});

  final ResumenDevolucionesProveedor resumen;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.espaciado.md,
      children: [
        Expanded(
          child: CifraDelDia(
            titulo: 'Devuelto este mes',
            valor: formatearDolares(resumen.devuelto),
            detalle: resumen.cuantas == 1
                ? '1 devolución'
                : '${resumen.cuantas} devoluciones',
          ),
        ),
        Expanded(
          child: CifraDelDia(
            titulo: 'Descontado de facturas',
            valor: formatearDolares(resumen.descontado),
            detalle: 'baja las cuentas por pagar',
          ),
        ),
        Expanded(
          child: CifraDelDia(
            titulo: 'Esperando reposición',
            valor: '${resumen.pendientes}',
            detalle: 'el proveedor aún no lo trae',
          ),
        ),
      ],
    );
  }
}

class _Tabla extends StatelessWidget {
  const _Tabla({
    required this.devoluciones,
    required this.elegida,
    required this.onElegir,
  });

  final ControladorDevolucionesProveedor devoluciones;
  final DevolucionProveedor? elegida;
  final ValueChanged<DevolucionProveedor> onElegir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final suave = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    final todas = devoluciones.todas;
    return Card(
      child: todas.isEmpty
          ? Padding(
              padding: EdgeInsets.all(espaciado.xl),
              child: Text(
                'Aún no hay devoluciones a proveedores',
                textAlign: TextAlign.center,
                style: suave,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.all(espaciado.md),
                  child: ColumnasDevolucion(
                    celdas: [
                      Text('Fecha', style: suave),
                      Text('Proveedor', style: suave),
                      Text('Qué se devolvió', style: suave),
                      Text('Valor', textAlign: TextAlign.right, style: suave),
                      Text('Cómo compensó', style: suave),
                    ],
                  ),
                ),
                for (final d in todas)
                  FilaDevolucionProveedor(
                    devolucion: d,
                    hoy: devoluciones.hoy,
                    factura: devoluciones.facturaDe(d.compraId),
                    elegida: d.id == elegida?.id,
                    onElegir: () => onElegir(d),
                  ),
              ],
            ),
    );
  }
}
