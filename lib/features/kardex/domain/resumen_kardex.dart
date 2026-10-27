import 'package:inventario/features/kardex/domain/linea_kardex.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';

/// Totals over some kardex rows: what came in, was sold and was lost.
class ResumenKardex {
  const ResumenKardex({
    required this.entro,
    required this.entradas,
    required this.vendido,
    required this.ventas,
    required this.perdido,
  });

  factory ResumenKardex.de(List<LineaKardex> lineas) {
    int sumar(GrupoMovimiento grupo, int Function(LineaKardex) cuanto) => lineas
        .where((l) => l.movimiento.tipo.grupo == grupo)
        .fold(0, (total, l) => total + cuanto(l));
    return ResumenKardex(
      entro: sumar(GrupoMovimiento.entradas, (l) => l.entra),
      entradas: lineas
          .where((l) => l.movimiento.tipo.grupo == GrupoMovimiento.entradas)
          .length,
      vendido: sumar(GrupoMovimiento.ventas, (l) => l.sale),
      ventas: lineas
          .where((l) => l.movimiento.tipo.grupo == GrupoMovimiento.ventas)
          .length,
      perdido: sumar(GrupoMovimiento.perdidas, (l) => l.sale),
    );
  }

  /// Scaled like the product's quantity.
  final int entro;
  final int entradas;
  final int vendido;
  final int ventas;
  final int perdido;

  @override
  bool operator ==(Object other) =>
      other is ResumenKardex &&
      other.entro == entro &&
      other.entradas == entradas &&
      other.vendido == vendido &&
      other.ventas == ventas &&
      other.perdido == perdido;

  @override
  int get hashCode => Object.hash(entro, entradas, vendido, ventas, perdido);
}
