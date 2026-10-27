import 'package:inventario/core/texto.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';

/// The figures on top of the incidents screen.
class ResumenIncidencias {
  const ResumenIncidencias({
    required this.abiertas,
    required this.delMes,
    this.proveedorConMas,
    this.deEseProveedor = 0,
  });

  factory ResumenIncidencias.de(List<Incidencia> incidencias, DateTime hoy) {
    final delMes = [
      for (final i in incidencias)
        if (i.fecha.year == hoy.year && i.fecha.month == hoy.month) i,
    ];
    final cuentas = <String, ({String nombre, int total})>{};
    for (final i in delMes) {
      final clave = normalizarParaBusqueda(i.proveedor);
      final previa = cuentas[clave]?.total ?? 0;
      cuentas[clave] = (nombre: i.proveedor, total: previa + 1);
    }
    ({String nombre, int total})? mayor;
    for (final cuenta in cuentas.values) {
      if (mayor == null || cuenta.total > mayor.total) mayor = cuenta;
    }
    return ResumenIncidencias(
      abiertas: incidencias.where((i) => i.abierta).length,
      delMes: delMes.length,
      proveedorConMas: mayor?.nombre,
      deEseProveedor: mayor?.total ?? 0,
    );
  }

  final int abiertas;

  /// Registered this calendar month.
  final int delMes;

  /// The supplier with most incidents this month; null when there are none.
  final String? proveedorConMas;
  final int deEseProveedor;

  @override
  bool operator ==(Object other) =>
      other is ResumenIncidencias &&
      other.abiertas == abiertas &&
      other.delMes == delMes &&
      other.proveedorConMas == proveedorConMas &&
      other.deEseProveedor == deEseProveedor;

  @override
  int get hashCode =>
      Object.hash(abiertas, delMes, proveedorConMas, deEseProveedor);
}
