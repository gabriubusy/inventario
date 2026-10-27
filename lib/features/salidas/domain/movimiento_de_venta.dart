import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/domain/vender.dart';

/// The history line of [salida] out of [antes] (the product right before
/// it), with its amount, cost and rate copied as they are now.
Movimiento movimientoDeVenta(
  Producto antes,
  Salida salida, {
  required DateTime fecha,
  int? tasa,
  String? ventaId,
}) {
  final lote = antes.lotes[indiceLoteDeSalida(antes, salida)];
  return Movimiento(
    fecha: fecha,
    tipo: TipoMovimiento.venta,
    productoId: antes.id,
    producto: antes.nombre,
    forma: antes.forma,
    marca: salida.marca,
    proveedor: salida.proveedor,
    piezas: salida.piezas,
    cantidad: salida.cantidad,
    importe: importeDeSalida(
      antes,
      lote,
      salida.cantidad,
      presentacion: salida.presentacion,
    ),
    abrioPieza: abrePieza(lote, salida.modo),
    costo: costoDeSalida(antes, lote, salida.cantidad),
    tasa: tasa,
    nota: salida.nota,
    ventaId: ventaId,
  );
}
