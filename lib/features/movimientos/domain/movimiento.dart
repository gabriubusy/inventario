import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

/// One stock movement (sale, entry, merma…), the history behind the kardex.
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
    this.costo,
    this.abrioPieza = false,
    this.anulada = false,
    this.tasa,
    this.nota = '',
    this.origenId,
    this.ventaId,
    this.medioReembolso,
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

  /// What a sale's goods cost, in dollar hundredths; null if unknown.
  final int? costo;

  /// A sale by weight that had to open a piece, which cancelling closes.
  final bool abrioPieza;

  /// A cancelled sale stays in the list, crossed out, and counts for nothing.
  final bool anulada;

  /// Bs per dollar (hundredths) used for a sale, so old totals in Bs don't
  /// move with later rates; null when there was none.
  final int? tasa;

  /// Why it happened: a merma's reason, what a count found, a note.
  final String nota;

  /// The sale a customer return belongs to; null otherwise.
  final String? origenId;

  /// The paid ticket a sale line belongs to; null for one-product sales.
  final String? ventaId;

  /// How a customer return's money was handed back; null for everything
  /// else and for returns made before it was asked (taken as dollar cash).
  final MedioPago? medioReembolso;

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
    costo: costo,
    abrioPieza: abrioPieza,
    anulada: anulada ?? this.anulada,
    tasa: tasa,
    nota: nota,
    origenId: origenId,
    ventaId: ventaId,
    medioReembolso: medioReembolso,
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
      other.costo == costo &&
      other.abrioPieza == abrioPieza &&
      other.anulada == anulada &&
      other.tasa == tasa &&
      other.nota == nota &&
      other.origenId == origenId &&
      other.ventaId == ventaId &&
      other.medioReembolso == medioReembolso;

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
    costo,
    abrioPieza,
    anulada,
    tasa,
    nota,
    origenId,
    ventaId,
    medioReembolso,
  );
}
