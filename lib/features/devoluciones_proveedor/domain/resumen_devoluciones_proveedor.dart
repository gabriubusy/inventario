import 'package:inventario/features/devoluciones_proveedor/domain/compensacion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/devolucion_proveedor.dart';

/// The figures on top of the supplier returns list, for the current month.
class ResumenDevolucionesProveedor {
  const ResumenDevolucionesProveedor({
    required this.devuelto,
    required this.cuantas,
    required this.descontado,
    required this.pendientes,
  });

  factory ResumenDevolucionesProveedor.de(
    List<DevolucionProveedor> devoluciones,
    DateTime hoy,
  ) {
    final delMes = devoluciones.where(
      (d) => d.fecha.year == hoy.year && d.fecha.month == hoy.month,
    );
    return ResumenDevolucionesProveedor(
      devuelto: delMes.fold(0, (t, d) => t + d.total),
      cuantas: delMes.length,
      descontado: delMes
          .where((d) => d.compensacion == Compensacion.descuento)
          .fold(0, (t, d) => t + d.total),
      pendientes: devoluciones.where((d) => d.pendiente).length,
    );
  }

  /// Dollar hundredths sent back this month.
  final int devuelto;
  final int cuantas;

  /// Dollar hundredths of this month taken off invoices.
  final int descontado;

  /// Returns, of any month, still waiting for the goods.
  final int pendientes;

  @override
  bool operator ==(Object other) =>
      other is ResumenDevolucionesProveedor &&
      other.devuelto == devuelto &&
      other.cuantas == cuantas &&
      other.descontado == descontado &&
      other.pendientes == pendientes;

  @override
  int get hashCode => Object.hash(devuelto, cuantas, descontado, pendientes);
}
