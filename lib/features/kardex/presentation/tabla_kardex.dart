import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/kardex/domain/linea_kardex.dart';
import 'package:inventario/features/kardex/presentation/fila_kardex.dart';

/// The product's movements, as a sliver: over a year a single product can
/// pile up thousands of rows, and building them all at once froze the
/// screen. The card is drawn behind the list so it looks the same.
class TablaKardex extends StatelessWidget {
  const TablaKardex({
    super.key,
    required this.lineas,
    required this.unidad,
    required this.hoy,
  });

  final List<LineaKardex> lineas;
  final UnidadBase unidad;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final encabezado = tema.textTheme.labelSmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    Widget derecha(String texto) =>
        Text(texto, textAlign: TextAlign.right, style: encabezado);
    return DecoratedSliver(
      decoration: BoxDecoration(
        color: tema.colorScheme.surface,
        border: Border.all(color: tema.colorScheme.outlineVariant),
        borderRadius: TemaApp.radioTarjeta,
      ),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: espaciado.lg,
                vertical: espaciado.md,
              ),
              child: ColumnasKardex(
                fecha: Text('FECHA', style: encabezado),
                tipo: Text('MOVIMIENTO', style: encabezado),
                detalle: Text('DETALLE', style: encabezado),
                entra: derecha('ENTRA'),
                sale: derecha('SALE'),
                saldo: derecha('SALDO'),
              ),
            ),
          ),
          if (lineas.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(espaciado.xl),
                child: Text(
                  'Sin movimientos en este periodo',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          SliverList.builder(
            itemCount: lineas.length,
            itemBuilder: (_, i) =>
                FilaKardex(linea: lineas[i], unidad: unidad, hoy: hoy),
          ),
        ],
      ),
    );
  }
}
