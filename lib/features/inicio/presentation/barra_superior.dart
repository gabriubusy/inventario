import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/logo_inventario.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/inicio/presentation/enlaces_cabecera.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/presentation/boton_tasa.dart';

/// Home header: menu and name on the left, the rate and its calculator in
/// the centre, the daily links on the right.
class BarraSuperior extends StatelessWidget {
  const BarraSuperior({
    super.key,
    required this.tasa,
    required this.onTasa,
    required this.onCalculadora,
    required this.onCaja,
    this.onGasto,
  });

  /// Room the right side needs for the till alone and with expenses.
  static const _anchoUnFijo = 140.0;
  static const _anchoDosFijos = 310.0;

  final ControladorTasa tasa;
  final VoidCallback onTasa;
  final VoidCallback onCalculadora;
  final VoidCallback onCaja;

  /// Null hides the expenses link (tests).
  final VoidCallback? onGasto;

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
        padding: EdgeInsets.fromLTRB(
          espaciado.lg,
          espaciado.md,
          espaciado.xxl,
          espaciado.md,
        ),
        child: Row(
          spacing: espaciado.md,
          children: [
            // Both sides take the same share, so the rate stays centred.
            Expanded(
              child: Row(
                spacing: espaciado.md,
                children: [
                  IconButton(
                    tooltip: 'Menú',
                    color: colores.primary,
                    icon: const Icon(Icons.menu),
                    onPressed: Scaffold.of(context).openDrawer,
                  ),
                  LogoInventario(tamano: espaciado.xl + espaciado.lg),
                  // The date gives way first when the window is narrow.
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        text: 'Inventario',
                        style: tema.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: '  · ${formatearFechaLarga(DateTime.now())}',
                            style: tema.textTheme.bodyMedium?.copyWith(
                              color: colores.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            ListenableBuilder(
              listenable: tasa,
              builder: (context, _) =>
                  BotonTasa(controlador: tasa, onPulsar: onTasa),
            ),
            EnlacesCabecera(
              enlaces: [
                (
                  texto: 'Calculadora',
                  atajo: 'Ctrl+R',
                  onPressed: onCalculadora,
                ),
              ],
            ),
            Expanded(
              // The till and expenses are daily: they stay in view
              // while there is room for them; the menu has them too.
              child: LayoutBuilder(
                builder: (context, lado) => Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: EnlacesCabecera(
                      enlaces: [
                        if (lado.maxWidth >= _anchoUnFijo)
                          (texto: 'Caja', atajo: 'F11', onPressed: onCaja),
                        if (lado.maxWidth >= _anchoDosFijos)
                          if (onGasto case final gasto?)
                            (texto: 'Gasto', atajo: 'Ctrl+G', onPressed: gasto),
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
