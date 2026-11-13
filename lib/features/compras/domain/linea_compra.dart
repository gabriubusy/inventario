import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

/// One product and brand on a supplier's invoice; already validated.
class LineaCompra {
  const LineaCompra({
    required this.productoId,
    required this.producto,
    required this.forma,
    required this.marca,
    this.piezas = 0,
    required this.cantidad,
    required this.costo,
    this.piezasRecibidas,
    this.cantidadRecibida,
  });

  final String productoId;

  /// Name and way of counting when bought, to show the invoice later.
  final String producto;
  final FormaConteo forma;
  final String marca;

  /// Whole pieces ordered; 0 for products not counted in pieces.
  final int piezas;

  /// Scaled by the product's unit, like [LoteMarca.cantidad].
  final int cantidad;

  /// Dollar hundredths per kg, l or und.
  final int costo;

  /// Pieces that really arrived; null while the line is still waiting.
  final int? piezasRecibidas;

  /// Scaled amount that really arrived; null while the line is waiting.
  final int? cantidadRecibida;

  bool get recibida => cantidadRecibida != null;

  /// What arrived, or what was ordered while nothing is confirmed.
  int get piezasLlegadas => piezasRecibidas ?? piezas;
  int get cantidadLlegada => cantidadRecibida ?? cantidad;

  /// Negative when the supplier brought less than the invoice says.
  int get diferencia => cantidadLlegada - cantidad;
  int get diferenciaPiezas => piezasLlegadas - piezas;

  bool get tieneDiferencia =>
      recibida && (diferencia != 0 || diferenciaPiezas != 0);

  /// Cost × quantity ordered, in dollar hundredths; the invoice's amount.
  int get subtotal => _valor(cantidad);

  /// Cost × what arrived, in dollar hundredths; 0 while it is waiting.
  int get subtotalRecibido => recibida ? _valor(cantidadRecibida!) : 0;

  int _valor(int cantidad) =>
      dividirRedondeando(costo * cantidad, forma.unidad.fraccionesPorUnidad);

  LineaCompra conRecibido({required int piezas, required int cantidad}) =>
      _con(piezasRecibidas: piezas, cantidadRecibida: cantidad);

  /// Back to waiting, to undo a reception.
  LineaCompra get sinRecibir => _con();

  LineaCompra _con({int? piezasRecibidas, int? cantidadRecibida}) =>
      LineaCompra(
        productoId: productoId,
        producto: producto,
        forma: forma,
        marca: marca,
        piezas: piezas,
        cantidad: cantidad,
        costo: costo,
        piezasRecibidas: piezasRecibidas,
        cantidadRecibida: cantidadRecibida,
      );

  @override
  bool operator ==(Object other) =>
      other is LineaCompra &&
      other.productoId == productoId &&
      other.producto == producto &&
      other.forma == forma &&
      other.marca == marca &&
      other.piezas == piezas &&
      other.cantidad == cantidad &&
      other.costo == costo &&
      other.piezasRecibidas == piezasRecibidas &&
      other.cantidadRecibida == cantidadRecibida;

  @override
  int get hashCode => Object.hash(
    productoId,
    producto,
    forma,
    marca,
    piezas,
    cantidad,
    costo,
    piezasRecibidas,
    cantidadRecibida,
  );
}
