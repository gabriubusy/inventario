import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/kardex/domain/filtro_kardex.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';

/// Group (Alt+1–4), period (Alt+P) and brand.
class FiltrosKardex extends StatelessWidget {
  const FiltrosKardex({
    super.key,
    required this.grupo,
    required this.periodo,
    required this.marcas,
    required this.marca,
    required this.onGrupo,
    required this.onPeriodo,
    required this.onMarca,
  });

  static const etiquetasGrupo = {
    null: 'Todo',
    GrupoMovimiento.ventas: 'Ventas',
    GrupoMovimiento.entradas: 'Entradas',
    GrupoMovimiento.perdidas: 'Pérdidas',
  };

  final GrupoMovimiento? grupo;
  final PeriodoKardex periodo;
  final List<String> marcas;

  /// Null means every brand.
  final String? marca;
  final ValueChanged<GrupoMovimiento?> onGrupo;
  final ValueChanged<PeriodoKardex> onPeriodo;
  final ValueChanged<String?> onMarca;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final espaciado = context.espaciado;
    return Wrap(
      spacing: espaciado.md,
      runSpacing: espaciado.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ExcludeFocus(
          child: SegmentedButton<GrupoMovimiento?>(
            showSelectedIcon: false,
            segments: [
              for (final (i, MapEntry(key: valor, value: texto))
                  in etiquetasGrupo.entries.indexed)
                ButtonSegment(
                  value: valor,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: espaciado.sm,
                    children: [
                      Text(texto),
                      TeclaAtajo(
                        'Alt+${i + 1}',
                        color: colores.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
            ],
            selected: {grupo},
            onSelectionChanged: (valor) => onGrupo(valor.first),
          ),
        ),
        DropdownButton<PeriodoKardex>(
          value: periodo,
          focusColor: Colors.transparent,
          items: [
            for (final p in PeriodoKardex.values)
              DropdownMenuItem(value: p, child: Text(p.etiqueta)),
          ],
          onChanged: (p) => p == null ? null : onPeriodo(p),
        ),
        TeclaAtajo('Alt+P', color: colores.onSurfaceVariant),
        if (marcas.length > 1)
          DropdownButton<String?>(
            value: marca,
            focusColor: Colors.transparent,
            items: [
              const DropdownMenuItem(child: Text('Todas las marcas')),
              for (final m in marcas)
                DropdownMenuItem(value: m, child: Text(m)),
            ],
            onChanged: onMarca,
          ),
      ],
    );
  }
}
