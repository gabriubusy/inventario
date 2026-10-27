import 'package:inventario/features/ajustes/domain/tipo_ajuste.dart';

/// A merma or loss from one brand lot; already validated.
class Ajuste {
  const Ajuste({
    required this.tipo,
    required this.motivo,
    required this.marca,
    this.proveedor = '',
    this.piezas = 0,
    required this.cantidad,
    this.nota = '',
  });

  final TipoAjuste tipo;
  final String motivo;
  final String marca;
  final String proveedor;

  /// Whole pieces lost; 0 when only weight or not counted in pieces.
  final int piezas;

  /// Scaled by the product's unit, like [LoteMarca.cantidad].
  final int cantidad;
  final String nota;

  @override
  bool operator ==(Object other) =>
      other is Ajuste &&
      other.tipo == tipo &&
      other.motivo == motivo &&
      other.marca == marca &&
      other.proveedor == proveedor &&
      other.piezas == piezas &&
      other.cantidad == cantidad &&
      other.nota == nota;

  @override
  int get hashCode =>
      Object.hash(tipo, motivo, marca, proveedor, piezas, cantidad, nota);
}
