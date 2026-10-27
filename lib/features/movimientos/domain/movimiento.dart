import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

/// One sale or entry, kept to show what happened during the day.
class Movimiento {
  const Movimiento({
    this.id = '',
    required this.fecha,
    required this.tipo,
    required this.productoId,
    required this.producto,
    required this.forma,
    required this.marca,
    this.proveedor = '',
    this.piezas = 0,
    required this.cantidad,
    this.importe,
    this.abrioPieza = false,
    this.anulada = false,
  });

  /// Empty until the repository stores it.
  final String id;
  final DateTime fecha;
  final TipoMovimiento tipo;
  final String productoId;

  /// Product name and way of counting at that moment, to show it later.
  final String producto;
  final FormaConteo forma;

  /// Brand and supplier of the lot it moved, to put a cancelled sale back.
  final String marca;
  final String proveedor;

  /// Whole pieces that moved; 0 when none.
  final int piezas;

  /// Scaled by the product's unit, like [LoteMarca.cantidad].
  final int cantidad;

  /// Sale amount in dollar hundredths; null for entries or without a price.
  final int? importe;

  /// A sale by weight that had to open a piece, which cancelling closes.
  final bool abrioPieza;

  /// A cancelled sale stays in the list, crossed out, and counts for nothing.
  final bool anulada;

  Movimiento _con({String? id, DateTime? fecha, bool? anulada}) => Movimiento(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    tipo: tipo,
    productoId: productoId,
    producto: producto,
    forma: forma,
    marca: marca,
    proveedor: proveedor,
    piezas: piezas,
    cantidad: cantidad,
    importe: importe,
    abrioPieza: abrioPieza,
    anulada: anulada ?? this.anulada,
  );

  Movimiento conId(String id) => _con(id: id);

  Movimiento conFecha(DateTime fecha) => _con(fecha: fecha);

  Movimiento anulado() => _con(anulada: true);

  @override
  bool operator ==(Object other) =>
      other is Movimiento &&
      other.id == id &&
      other.fecha == fecha &&
      other.tipo == tipo &&
      other.productoId == productoId &&
      other.producto == producto &&
      other.forma == forma &&
      other.marca == marca &&
      other.proveedor == proveedor &&
      other.piezas == piezas &&
      other.cantidad == cantidad &&
      other.importe == importe &&
      other.abrioPieza == abrioPieza &&
      other.anulada == anulada;

  @override
  int get hashCode => Object.hash(
    id,
    fecha,
    tipo,
    productoId,
    producto,
    forma,
    marca,
    proveedor,
    piezas,
    cantidad,
    importe,
    abrioPieza,
    anulada,
  );
}
