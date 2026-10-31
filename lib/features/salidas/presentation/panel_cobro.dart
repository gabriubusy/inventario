import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/salidas/domain/resumen_cobro.dart';

/// What is still missing, or the change to hand back in $ and Bs.
class PanelCobro extends StatelessWidget {
  const PanelCobro({super.key, required this.cobro, this.escritoCorto = false});

  final ResumenCobro cobro;

  /// The typed amount falls short: Enter adds it and asks for the rest.
  final bool escritoCorto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    const cifras = [FontFeature.tabularFigures()];
    final (titulo, cifra, detalle, fondo, texto) = cobro.vueltoSinEfectivo
        ? (
            'Pagó de más',
            formatearDolares(cobro.vuelto),
            'Sin efectivo no hay vuelto: revisa el monto',
            context.coloresEstado.fondoAgotado,
            context.coloresEstado.textoAgotado,
          )
        : cobro.falta > 0
        ? (
            'Falta',
            formatearDolares(cobro.falta),
            // In both currencies: the rest is often paid in bolívares.
            'o ${formatearBolivares(cobro.faltaEnBolivares)} · '
                '${escritoCorto ? 'Enter añade este pago y cobra el resto' : 'Enter la cobra exacta · Ctrl+M otro pago'}',
            colores.surfaceContainerLowest,
            colores.onSurface,
          )
        : (
            'Vuelto',
            formatearDolares(cobro.vuelto),
            'o ${formatearBolivares(cobro.vueltoEnBolivares)}',
            context.coloresEstado.fondoBien,
            context.coloresEstado.textoBien,
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fondo,
        border: Border.all(color: colores.outlineVariant),
        borderRadius: BorderRadius.circular(espaciado.md),
      ),
      child: Padding(
        padding: EdgeInsets.all(espaciado.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: tema.textTheme.titleSmall?.copyWith(
                color: texto,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              cifra,
              style: tema.textTheme.headlineMedium?.copyWith(
                color: texto,
                fontWeight: FontWeight.w700,
                fontFeatures: cifras,
              ),
            ),
            Text(
              detalle,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: texto,
                fontFeatures: cifras,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
