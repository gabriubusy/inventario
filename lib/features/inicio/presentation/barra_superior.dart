import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/logo_inventario.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/inicio/presentation/enlaces_cabecera.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/presentation/boton_tasa.dart';

class BarraSuperior extends StatelessWidget {
  const BarraSuperior({
    super.key,
    required this.tasa,
    required this.onTasa,
    required this.onProveedores,
    required this.onIncidencias,
    required this.onKardex,
    required this.onConteo,
    required this.onCuentas,
    required this.onCaja,
    required this.onReportes,
    required this.onBloquear,
    required this.onCambiarPin,
    this.onConfiguracion,
    this.onGasto,
    this.onIncidencia,
    this.onDevolver,
  });

  /// Below this width the links fold into a menu instead of shrinking.
  static const _anchoEnlaces = 3400.0;
  static const _anchoUnFijo = 1000.0;
  static const _anchoDosFijos = 1100.0;

  /// Ctrl+G, Ctrl+I and Ctrl+D, listed so they can be found; null hides.
  final VoidCallback? onGasto;
  final VoidCallback? onIncidencia;
  final VoidCallback? onDevolver;

  final ControladorTasa tasa;
  final VoidCallback onTasa;
  final VoidCallback onProveedores;
  final VoidCallback onIncidencias;
  final VoidCallback onKardex;
  final VoidCallback onConteo;
  final VoidCallback onCuentas;
  final VoidCallback onCaja;
  final VoidCallback onReportes;
  final VoidCallback onBloquear;
  final VoidCallback onCambiarPin;

  /// Null where Configuración is not offered (tests).
  final VoidCallback? onConfiguracion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surface,
        border: Border(bottom: BorderSide(color: colores.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.xxl,
          vertical: espaciado.md,
        ),
        child: LayoutBuilder(
          builder: (context, limites) => Row(
            spacing: espaciado.md,
            children: [
              LogoInventario(tamano: espaciado.xl + espaciado.lg),
              Text(
                'Inventario',
                style: tema.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              // The date gives way first when the window is narrow.
              Expanded(
                child: Text(
                  '· ${formatearFechaLarga(DateTime.now())}',
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: colores.onSurfaceVariant,
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: tasa,
                builder: (context, _) =>
                    BotonTasa(controlador: tasa, onPulsar: onTasa),
              ),
              EnlacesCabecera(
                compacto: limites.maxWidth < _anchoEnlaces,
                // The till and expenses are daily: they stay in view
                // while there is room for them.
                fijos: limites.maxWidth >= _anchoDosFijos && onGasto != null
                    ? 2
                    : limites.maxWidth >= _anchoUnFijo
                    ? 1
                    : 0,
                enlaces: [
                  (texto: 'Caja', atajo: 'F11', onPressed: onCaja),
                  if (onGasto case final gasto?)
                    (texto: 'Gasto', atajo: 'Ctrl+G', onPressed: gasto),
                  (texto: 'Proveedores', atajo: 'F5', onPressed: onProveedores),
                  (texto: 'Incidencias', atajo: 'F6', onPressed: onIncidencias),
                  if (onIncidencia case final incidencia?)
                    (
                      texto: 'Registrar incidencia',
                      atajo: 'Ctrl+I',
                      onPressed: incidencia,
                    ),
                  if (onDevolver case final devolver?)
                    (
                      texto: 'Devolver a proveedor',
                      atajo: 'Ctrl+D',
                      onPressed: devolver,
                    ),
                  (texto: 'Kardex', atajo: 'F8', onPressed: onKardex),
                  (texto: 'Conteo', atajo: 'F9', onPressed: onConteo),
                  (texto: 'Cuentas', atajo: 'F10', onPressed: onCuentas),
                  (texto: 'Reportes', atajo: 'F12', onPressed: onReportes),
                  if (onConfiguracion case final abrir?)
                    (texto: 'Configuración', atajo: 'Ctrl+,', onPressed: abrir),
                  (
                    texto: 'Cambiar PIN',
                    atajo: 'Ctrl+Shift+L',
                    onPressed: onCambiarPin,
                  ),
                  (texto: 'Bloquear', atajo: 'Ctrl+L', onPressed: onBloquear),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
