import 'package:inventario/features/incidencias/domain/sacar_de_lote.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// Why that amount cannot come out of the lot, in red under the fields.
String textoNoSale(
  Producto producto,
  LoteMarca lote, {
  required int piezas,
  required int cantidad,
}) {
  if (!dejaPiezasSinPeso(lote, piezas: piezas, cantidad: cantidad)) {
    return 'Solo hay ${textoLote(producto, lote)}';
  }
  final quedan = lote.piezas - piezas;
  return 'Quedarían $quedan ${quedan == 1 ? 'pieza' : 'piezas'} sin peso: '
      'pon cuántas piezas se van o menos peso';
}
