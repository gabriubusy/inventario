import 'package:inventario/core/fechas.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';

/// The best seller of the day and what it brought in.
typedef MasVendido = ({
  String producto,
  int importe,
  int cantidad,
  UnidadBase unidad,
});

/// The figures on top of the home screen, for one calendar day.
class ResumenDia {
  const ResumenDia({
    required this.vendido,
    required this.ventas,
    required this.gramos,
    required this.unidades,
    required this.entradas,
    this.masVendido,
  });

  factory ResumenDia.de(List<Movimiento> movimientos, DateTime hoy) {
    final delDia = [
      for (final m in movimientos)
        if (diasEntre(m.fecha, hoy) == 0) m,
    ];
    // A cancelled sale gave its goods back, so it counts for nothing.
    final ventas = [
      for (final m in delDia)
        if (m.tipo == TipoMovimiento.venta && !m.anulada) m,
    ];
    final devoluciones = [
      for (final m in delDia)
        if (m.tipo == TipoMovimiento.devolucionCliente) m,
    ];
    // What customers brought back today no longer counts as sold.
    int sumar(UnidadBase unidad) {
      int de(List<Movimiento> lineas) => lineas
          .where((m) => m.forma.unidad == unidad)
          .fold(0, (total, m) => total + m.cantidad);
      return de(ventas) - de(devoluciones);
    }

    final porProducto = <String, MasVendido>{};
    for (final m in ventas) {
      final previo = porProducto[m.productoId];
      porProducto[m.productoId] = (
        producto: m.producto,
        importe: (previo?.importe ?? 0) + (m.importe ?? 0),
        cantidad: (previo?.cantidad ?? 0) + m.cantidad,
        unidad: m.forma.unidad,
      );
    }
    MasVendido? mas;
    for (final p in porProducto.values) {
      if (mas == null || p.importe > mas.importe) mas = p;
    }
    // Money handed back to customers today comes off what was sold.
    final devuelto = devoluciones.fold(
      0,
      (total, m) => total + (m.importe ?? 0),
    );
    return ResumenDia(
      vendido:
          ventas.fold(0, (total, m) => total + (m.importe ?? 0)) - devuelto,
      // One customer's ticket is one sale, however many products it has.
      ventas:
          ventas.where((m) => m.ventaId == null).length +
          {for (final m in ventas) ?m.ventaId}.length,
      gramos: sumar(UnidadBase.kg),
      unidades: sumar(UnidadBase.unidad),
      entradas: delDia.where((m) => m.tipo == TipoMovimiento.entrada).length,
      masVendido: mas,
    );
  }

  /// Dollar hundredths, minus customer refunds; sales without a price add
  /// nothing.
  final int vendido;

  /// Tickets, not lines.
  final int ventas;

  /// Weight sold, scaled like [UnidadBase.kg].
  final int gramos;
  final int unidades;
  final int entradas;

  /// By amount; null when nothing was sold.
  final MasVendido? masVendido;

  @override
  bool operator ==(Object other) =>
      other is ResumenDia &&
      other.vendido == vendido &&
      other.ventas == ventas &&
      other.gramos == gramos &&
      other.unidades == unidades &&
      other.entradas == entradas &&
      other.masVendido == masVendido;

  @override
  int get hashCode =>
      Object.hash(vendido, ventas, gramos, unidades, entradas, masVendido);
}
