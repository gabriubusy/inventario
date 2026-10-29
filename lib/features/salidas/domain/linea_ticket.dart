import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/salidas/domain/salida.dart';

/// One product in the ticket being rung up, not yet taken from the stock.
class LineaTicket {
  const LineaTicket({
    required this.productoId,
    required this.producto,
    required this.forma,
    required this.salida,
    this.importe,
  });

  final String productoId;

  /// Name and way of counting, to show the line without looking it up.
  final String producto;
  final FormaConteo forma;
  final Salida salida;

  /// Dollar hundredths; null when the brand has no price.
  final int? importe;

  LineaTicket conImporte(int? importe) => LineaTicket(
    productoId: productoId,
    producto: producto,
    forma: forma,
    salida: salida,
    importe: importe,
  );

  @override
  bool operator ==(Object other) =>
      other is LineaTicket &&
      other.productoId == productoId &&
      other.producto == producto &&
      other.forma == forma &&
      other.salida == salida &&
      other.importe == importe;

  @override
  int get hashCode => Object.hash(productoId, producto, forma, salida, importe);
}
