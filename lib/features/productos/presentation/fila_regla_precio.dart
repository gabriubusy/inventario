import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/presentation/campo_cantidad.dart';
import 'package:inventario/features/productos/presentation/regla_editable.dart';

/// "Mayor  [Sin regla | Costo + % | Precio fijo]  [25 %]  Queda …".
class FilaReglaPrecio extends StatelessWidget {
  const FilaReglaPrecio({
    super.key,
    required this.lista,
    required this.regla,
    required this.unidad,
    required this.queda,
    required this.onTipo,
  });

  static const _anchoNombre = 72.0;
  static const _anchoValor = 140.0;

  final ListaPrecio lista;
  final ReglaEditable regla;
  final UnidadBase unidad;

  /// "Marca A $ 5,72 · Marca B $ 6,10", empty when nothing to show.
  final String queda;
  final ValueChanged<TipoRegla> onTipo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: espaciado.xs,
      children: [
        Wrap(
          spacing: espaciado.md,
          runSpacing: espaciado.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: _anchoNombre,
              child: Text(lista.etiqueta, style: tema.textTheme.bodyLarge),
            ),
            ExcludeFocus(
              child: SegmentedButton<TipoRegla>(
                showSelectedIcon: false,
                segments: [
                  for (final tipo in TipoRegla.values)
                    ButtonSegment(value: tipo, label: Text(tipo.etiqueta)),
                ],
                selected: {regla.tipo},
                onSelectionChanged: (elegidos) => onTipo(elegidos.first),
              ),
            ),
            if (regla.tipo != TipoRegla.ninguna)
              SizedBox(
                width: _anchoValor,
                child: CampoCantidad(
                  etiqueta: regla.tipo == TipoRegla.margen
                      ? 'Ganancia'
                      : 'Precio',
                  controller: regla.valor,
                  focusNode: regla.foco,
                  decimales: decimalesDinero,
                  sufijo: regla.tipo == TipoRegla.margen
                      ? '%'
                      : '\$/${unidad.simbolo}',
                ),
              ),
          ],
        ),
        if (queda.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: _anchoNombre + espaciado.md),
            child: Text(
              queda,
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
      ],
    );
  }
}
