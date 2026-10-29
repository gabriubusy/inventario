import 'package:inventario/core/listas.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';

/// A paid ticket: what it came to and how it was paid. Its products are the
/// sale movements that carry its id.
class Venta {
  const Venta({
    this.id = '',
    required this.fecha,
    required this.total,
    this.tasa,
    required this.pagos,
    this.lista = ListaPrecio.detal,
  });

  /// Empty until the repository stores it.
  final String id;
  final DateTime fecha;

  /// Dollar hundredths.
  final int total;

  /// Bs per dollar (hundredths) it was charged at; null without a rate.
  final int? tasa;
  final List<PagoVenta> pagos;

  /// The price list its lines were priced at.
  final ListaPrecio lista;

  Venta conId(String id) => Venta(
    id: id,
    fecha: fecha,
    total: total,
    tasa: tasa,
    pagos: pagos,
    lista: lista,
  );

  @override
  bool operator ==(Object other) =>
      other is Venta &&
      other.id == id &&
      other.fecha == fecha &&
      other.total == total &&
      other.tasa == tasa &&
      other.lista == lista &&
      listasIguales(other.pagos, pagos);

  @override
  int get hashCode =>
      Object.hash(id, fecha, total, tasa, lista, Object.hashAll(pagos));
}
