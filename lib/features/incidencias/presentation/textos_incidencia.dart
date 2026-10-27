import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// "2 piezas · 1,6 kg", or just "0,8 kg" when no whole piece was affected.
String textoAfectado(Incidencia incidencia) {
  final cantidad = incidencia.forma.unidad.formatear(incidencia.cantidad);
  if (incidencia.piezas == 0) return cantidad;
  return '${textoPiezas(incidencia.piezas)} · $cantidad';
}

/// "Abierta · 3 d" while open, else how the supplier answered.
String textoEstado(Incidencia incidencia, DateTime hoy) {
  final respuesta = incidencia.respuesta;
  if (respuesta != null) return respuesta.etiqueta;
  return 'Abierta · ${incidencia.diasAbierta(hoy)} d';
}
