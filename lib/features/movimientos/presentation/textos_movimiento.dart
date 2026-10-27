import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// "Marca A · 1,25 kg", or "Marca F · pieza 4,2 kg" for a whole piece.
String textoDetalleMovimiento(Movimiento movimiento) {
  final cantidad = movimiento.forma.unidad.formatear(movimiento.cantidad);
  final piezas = switch (movimiento.piezas) {
    0 => '',
    1 => 'pieza ',
    _ => '${textoPiezas(movimiento.piezas)} · ',
  };
  return '${movimiento.marca} · $piezas$cantidad';
}

/// "11:42"
String textoHora(DateTime fecha) =>
    '${fecha.hour.toString().padLeft(2, '0')}:'
    '${fecha.minute.toString().padLeft(2, '0')}';
