import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/kardex/domain/linea_kardex.dart';
import 'package:inventario/features/kardex/presentation/fila_kardex.dart';

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
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
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
          if (lineas.isEmpty)
            Padding(
              padding: EdgeInsets.all(espaciado.xl),
              child: Text(
                'Sin movimientos en este periodo',
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final linea in lineas)
            FilaKardex(linea: linea, unidad: unidad, hoy: hoy),
        ],
      ),
    );
  }
}
