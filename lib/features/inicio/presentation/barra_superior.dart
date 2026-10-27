import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
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
    required this.onBloquear,
    required this.onCambiarPin,
  });

  /// Below this width the links fold into a menu instead of shrinking.
  static const _anchoEnlaces = 1360.0;

  final ControladorTasa tasa;
  final VoidCallback onTasa;
  final VoidCallback onProveedores;
  final VoidCallback onIncidencias;
  final VoidCallback onBloquear;
  final VoidCallback onCambiarPin;

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
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colores.primary,
                  borderRadius: BorderRadius.circular(espaciado.sm),
                ),
                child: Padding(
                  padding: EdgeInsets.all(espaciado.sm),
                  child: Icon(
                    Icons.storefront_outlined,
                    size: espaciado.xl - 4,
                    color: colores.onPrimary,
                  ),
                ),
              ),
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
                enlaces: [
                  (texto: 'Proveedores', atajo: 'F5', onPressed: onProveedores),
                  (texto: 'Incidencias', atajo: 'F6', onPressed: onIncidencias),
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
