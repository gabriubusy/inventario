import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';

/// Goods that leave the stock without a sale (F3).
enum TipoAjuste {
  merma('Merma', TipoMovimiento.merma, [
    'Recorte',
    'Vencido',
    'Dañado',
    'Otro',
  ]),
  robo('Robo o pérdida', TipoMovimiento.robo, [
    'Robo',
    'Faltante sin explicar',
  ]);

  const TipoAjuste(this.etiqueta, this.movimiento, this.motivos);

  final String etiqueta;

  /// How it shows in the kardex.
  final TipoMovimiento movimiento;

  /// Quick reasons offered with Alt+1…; the first is preselected.
  final List<String> motivos;
}
