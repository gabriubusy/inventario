import 'package:flutter/material.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/presentation/lote_editable.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// Live total of the brand rows, e.g. "Total: 25 piezas · 20 kg · ≈ 0,8 kg por pieza".
class TotalLotes extends StatelessWidget {
  const TotalLotes({super.key, required this.lotes, required this.forma});

  final List<LoteEditable> lotes;
  final FormaConteo forma;

  String _texto() {
    final cantidad = lotes.fold(0, (t, l) => t + l.leerCantidad(forma));
    final unidad = forma.unidad;
    if (!forma.cuentaPiezas) return 'Total: ${unidad.formatear(cantidad)}';
    final piezas = lotes.fold(0, (t, l) => t + l.leerPiezas());
    final total =
        'Total: ${textoPiezas(piezas)} · ${unidad.formatear(cantidad)}';
    final promedio = textoPromedioPorPieza(cantidad, piezas, unidad);
    return promedio == null ? total : '$total · $promedio';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([for (final lote in lotes) lote.cambios]),
      builder: (context, _) => Text(
        _texto(),
        textAlign: TextAlign.right,
        style: tema.textTheme.bodyMedium?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
