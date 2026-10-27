import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// "1 saco + 11,5 kg": the stock in the biggest pack that fits and the rest.
typedef DesgloseStock = ({Presentacion presentacion, int paquetes, int resto});

/// Null when no pack is bigger than one base unit or not even one fits,
/// since "26,5 kg" alone already says it all then.
DesgloseStock? desglosarStock(Producto producto) {
  final unidad = producto.forma.unidad.fraccionesPorUnidad;
  final grandes = [
    for (final p in producto.presentaciones)
      if (p.factor > unidad) p,
  ]..sort((a, b) => b.factor.compareTo(a.factor));
  final cantidad = producto.cantidad;
  for (final presentacion in grandes) {
    final paquetes = cantidad ~/ presentacion.factor;
    if (paquetes > 0) {
      return (
        presentacion: presentacion,
        paquetes: paquetes,
        resto: cantidad - paquetes * presentacion.factor,
      );
    }
  }
  return null;
}
