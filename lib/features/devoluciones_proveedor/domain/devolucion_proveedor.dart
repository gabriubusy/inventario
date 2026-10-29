import 'package:inventario/core/listas.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/compensacion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/motivo_devolucion.dart';

/// Goods sent back to a supplier and how it makes up for them. Lines are
/// valued at their cost, like an invoice.
class DevolucionProveedor {
  const DevolucionProveedor({
    this.id = '',
    required this.fecha,
    required this.proveedor,
    required this.motivo,
    required this.lineas,
    required this.compensacion,
    this.compraId,
    this.medio,
    this.entregado,
    this.tasa,
    this.repuesta,
    this.nota = '',
    this.incidenciaId,
    this.sacada = true,
  });

  /// Empty until the repository stores it.
  final String id;
  final DateTime fecha;
  final String proveedor;
  final MotivoDevolucion motivo;
  final List<LineaCompra> lineas;
  final Compensacion compensacion;

  /// The invoice on credit it is taken off; only for a discount.
  final String? compraId;

  /// How the money came back; only when it is paid back.
  final MedioPago? medio;

  /// What came back, in hundredths of [medio]'s currency.
  final int? entregado;

  /// Bs per dollar (hundredths) used for money back in bolívares.
  final int? tasa;

  /// When the supplier brought the goods again; only for [Compensacion.repone].
  final DateTime? repuesta;
  final String nota;

  /// The incident it settles, when it came from one.
  final String? incidenciaId;

  /// False when the incident had already taken the goods out of stock.
  final bool sacada;

  /// In dollar hundredths.
  int get total => lineas.fold(0, (suma, l) => suma + l.subtotal);

  /// Still waiting for the supplier to bring the goods again.
  bool get pendiente => compensacion == Compensacion.repone && repuesta == null;

  DevolucionProveedor conId(String id) => _copia(id: id);

  DevolucionProveedor conProveedor(String proveedor) =>
      _copia(proveedor: proveedor);

  /// A null [fecha] puts it back as pending.
  DevolucionProveedor conRepuesta(DateTime? fecha) =>
      _copia(repuesta: fecha, cambiaRepuesta: true);

  DevolucionProveedor _copia({
    String? id,
    String? proveedor,
    DateTime? repuesta,
    bool cambiaRepuesta = false,
  }) => DevolucionProveedor(
    id: id ?? this.id,
    fecha: fecha,
    proveedor: proveedor ?? this.proveedor,
    motivo: motivo,
    lineas: lineas,
    compensacion: compensacion,
    compraId: compraId,
    medio: medio,
    entregado: entregado,
    tasa: tasa,
    repuesta: cambiaRepuesta ? repuesta : this.repuesta,
    nota: nota,
    incidenciaId: incidenciaId,
    sacada: sacada,
  );

  @override
  bool operator ==(Object other) =>
      other is DevolucionProveedor &&
      other.id == id &&
      other.fecha == fecha &&
      other.proveedor == proveedor &&
      other.motivo == motivo &&
      listasIguales(other.lineas, lineas) &&
      other.compensacion == compensacion &&
      other.compraId == compraId &&
      other.medio == medio &&
      other.entregado == entregado &&
      other.tasa == tasa &&
      other.repuesta == repuesta &&
      other.nota == nota &&
      other.incidenciaId == incidenciaId &&
      other.sacada == sacada;

  @override
  int get hashCode => Object.hash(
    id,
    fecha,
    proveedor,
    motivo,
    Object.hashAll(lineas),
    compensacion,
    compraId,
    medio,
    entregado,
    tasa,
    repuesta,
    nota,
    incidenciaId,
    sacada,
  );
}

/// Dollar hundredths taken off each invoice by discounts.
Map<String, int> devueltoPorCompra(Iterable<DevolucionProveedor> devoluciones) {
  final devuelto = <String, int>{};
  for (final d in devoluciones) {
    final compraId = d.compraId;
    if (d.compensacion != Compensacion.descuento || compraId == null) continue;
    devuelto[compraId] = (devuelto[compraId] ?? 0) + d.total;
  }
  return devuelto;
}
