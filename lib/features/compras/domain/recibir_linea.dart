import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/entradas/domain/entrada.dart';
import 'package:inventario/features/entradas/domain/sumar_entrada.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// The product with the line's goods added to its brand lot (or a new
/// one), and that lot's cost updated to what was just paid.
Producto recibirLinea(
  Producto producto,
  LineaCompra linea, {
  required String proveedor,
}) {
  final entrada = Entrada(
    marca: linea.marca,
    proveedor: proveedor,
    piezas: linea.piezas,
    cantidad: linea.cantidad,
  );
  final sumado = sumarEntrada(producto, entrada);
  final indice = indiceLoteDeEntrada(sumado, entrada);
  return sumado.copyWith(
    lotes: [
      for (final (i, lote) in sumado.lotes.indexed)
        i == indice ? lote.copyWith(costo: linea.costo) : lote,
    ],
  );
}
