import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/salidas/domain/linea_ticket.dart';
import 'package:inventario/features/salidas/domain/medida_venta.dart';

/// "Propia · 2 kg", "Dogui · 1 saco", "Marca A · 1 pieza, 0,84 kg".
String textoLineaTicket(LineaTicket linea) {
  final salida = linea.salida;
  final unidad = linea.forma.unidad;
  final presentacion = salida.presentacion;
  final cantidad = presentacion != null
      ? _enPaquetes(presentacion, salida.cantidad)
      : salida.piezas > 0
      ? '${textoPiezas(salida.piezas)}, ${unidad.formatear(salida.cantidad)}'
      : unidad.formatear(salida.cantidad);
  return '${salida.marca} · $cantidad';
}

/// "2 sacos", or "2,5 kilo" when it is not a whole number of packs.
String _enPaquetes(Presentacion presentacion, int cantidad) {
  if (cantidad % presentacion.factor == 0) {
    return textoPaquetes(presentacion, cantidad ~/ presentacion.factor);
  }
  final escrito = MedidaEnPresentacion(presentacion).desdeBase(cantidad);
  return '${formatDecimal(escrito, decimales: 3)} '
      '${presentacion.nombre.trim().toLowerCase()}';
}
