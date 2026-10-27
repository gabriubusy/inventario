import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

/// A new incident as typed; already validated.
class DatosIncidencia {
  const DatosIncidencia({
    required this.fecha,
    required this.proveedor,
    required this.productoId,
    required this.producto,
    required this.forma,
    required this.marca,
    required this.tipo,
    this.piezas = 0,
    required this.cantidad,
    this.nota = '',
    required this.sacada,
  });

  final DateTime fecha;

  /// Supplier name, the same link brand lots use.
  final String proveedor;
  final String productoId;

  /// Product name and way of counting when it happened, to show it later.
  final String producto;
  final FormaConteo forma;
  final String marca;
  final TipoIncidencia tipo;

  /// Whole pieces affected; 0 when only weight or not counted in pieces.
  final int piezas;

  /// Scaled by the product's unit, like [LoteMarca.cantidad].
  final int cantidad;
  final String nota;

  /// Whether the affected goods were taken out of the stock.
  final bool sacada;

  @override
  bool operator ==(Object other) =>
      other is DatosIncidencia &&
      other.fecha == fecha &&
      other.proveedor == proveedor &&
      other.productoId == productoId &&
      other.producto == producto &&
      other.forma == forma &&
      other.marca == marca &&
      other.tipo == tipo &&
      other.piezas == piezas &&
      other.cantidad == cantidad &&
      other.nota == nota &&
      other.sacada == sacada;

  @override
  int get hashCode => Object.hash(
    fecha,
    proveedor,
    productoId,
    producto,
    forma,
    marca,
    tipo,
    piezas,
    cantidad,
    nota,
    sacada,
  );
}
