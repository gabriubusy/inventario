import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/presentation/fila_lote.dart';
import 'package:inventario/features/productos/presentation/lote_editable.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/productos/presentation/total_lotes.dart';

/// One row per brand and supplier, with its price, plus the total.
class SeccionLotes extends StatelessWidget {
  const SeccionLotes({
    super.key,
    required this.lotes,
    required this.forma,
    required this.esRepetido,
    required this.onAgregar,
    required this.onQuitar,
    this.proveedores = const [],
    this.editando = false,
    this.aBolivares,
  });

  final List<LoteEditable> lotes;
  final FormaConteo forma;
  final List<String> proveedores;
  final bool Function(LoteEditable) esRepetido;
  final VoidCallback onAgregar;
  final ValueChanged<LoteEditable> onQuitar;

  /// Stock is typed only when creating; afterwards entries and sales move it.
  final bool editando;

  final int? Function(int dolares)? aBolivares;

  String? _existenciaFija(LoteEditable lote) {
    if (!editando) return null;
    final original = lote.original;
    return original == null
        ? 'Llega con entradas'
        : textoLoteSegun(forma, original);
  }

  bool _quitable(int indice, LoteEditable lote) =>
      editando ? !lote.tieneExistencia : indice > 0;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surfaceContainerLowest,
        border: Border.all(color: colores.outlineVariant),
        borderRadius: BorderRadius.circular(espaciado.sm + 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(espaciado.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: espaciado.sm,
          children: [
            Text.rich(
              TextSpan(
                text: editando ? 'Por marca ' : 'Hay ahora, por marca ',
                style: tema.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: editando
                        ? '· las existencias cambian con entradas, salidas y mermas'
                        : '(opcional)',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: colores.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            for (final (i, lote) in lotes.indexed)
              FilaLote(
                key: ObjectKey(lote),
                lote: lote,
                forma: forma,
                proveedores: proveedores,
                esRepetido: () => esRepetido(lote),
                existenciaFija: _existenciaFija(lote),
                aBolivares: aBolivares,
                onQuitar: _quitable(i, lote) ? () => onQuitar(lote) : null,
              ),
            Row(
              children: [
                ExcludeFocus(
                  child: TextButton.icon(
                    onPressed: onAgregar,
                    icon: const Icon(Icons.add),
                    label: Row(
                      spacing: espaciado.sm,
                      children: [
                        const Text('Otra marca'),
                        TeclaAtajo('Ctrl+M', color: colores.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TotalLotes(lotes: lotes, forma: forma),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
