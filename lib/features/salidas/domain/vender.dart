import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/domain/modo_venta.dart';
import 'package:inventario/features/salidas/domain/salida.dart';

/// Position of the lot the sale comes from, or -1 when it is gone.
int indiceLoteDeSalida(Producto producto, Salida salida) {
  final marca = normalizarParaBusqueda(salida.marca);
  final proveedor = normalizarParaBusqueda(salida.proveedor);
  return producto.lotes.indexWhere(
    (lote) =>
        normalizarParaBusqueda(lote.marca) == marca &&
        normalizarParaBusqueda(lote.proveedor) == proveedor,
  );
}

/// The most that can go out of [lote] this way, scaled like its quantity.
int disponibleParaVender(LoteMarca lote, ModoVenta? modo) => switch (modo) {
  ModoVenta.piezaEntera => lote.piezas > 0 ? lote.cantidad : 0,
  ModoVenta.porPeso => lote.piezaAbierta || lote.piezas > 0 ? lote.cantidad : 0,
  null => lote.cantidad,
};

/// A sale by weight with no open piece in the lot has to open one.
bool abrePieza(LoteMarca lote, ModoVenta? modo) =>
    modo == ModoVenta.porPeso && !lote.piezaAbierta;

/// The product after the sale; null when the lot is gone or short.
Producto? vender(Producto producto, Salida salida) {
  final indice = indiceLoteDeSalida(producto, salida);
  if (indice == -1) return null;
  final lote = producto.lotes[indice];
  if (salida.cantidad <= 0 ||
      salida.cantidad > disponibleParaVender(lote, salida.modo)) {
    return null;
  }
  final abre = abrePieza(lote, salida.modo);
  final restante = lote.cantidad - salida.cantidad;
  final vendido = lote.copyWith(
    piezas: lote.piezas - salida.piezas - (abre ? 1 : 0),
    // Nothing is left open once its weight is gone.
    piezaAbierta: (lote.piezaAbierta || abre) && restante > 0,
    cantidad: restante,
  );
  return producto.copyWith(
    lotes: [
      for (final (i, l) in producto.lotes.indexed) i == indice ? vendido : l,
    ],
  );
}

/// What the sale costs in dollar hundredths: by the pack's price when sold
/// in one, else by the brand's; null when there is no price.
int? importeDeSalida(
  Producto producto,
  LoteMarca lote,
  int cantidad, {
  Presentacion? presentacion,
}) {
  if (presentacion != null) {
    return dividirRedondeando(
      presentacion.precio * cantidad,
      presentacion.factor,
    );
  }
  final precio = lote.precio;
  if (precio == null) return null;
  return dividirRedondeando(
    precio * cantidad,
    producto.forma.unidad.fraccionesPorUnidad,
  );
}

/// What the goods sold cost the shop, from the brand's cost; null when the
/// brand has none. Kept with the sale so later profit stays right.
int? costoDeSalida(Producto producto, LoteMarca lote, int cantidad) {
  final costo = lote.costo;
  if (costo == null) return null;
  return dividirRedondeando(
    costo * cantidad,
    producto.forma.unidad.fraccionesPorUnidad,
  );
}

/// The lot offered first: an open piece for sales by weight, else the one
/// holding the most. Null when no brand has stock.
int? loteSugerido(Producto producto, ModoVenta? modo) {
  final candidatos = [
    for (final (i, lote) in producto.lotes.indexed)
      if (disponibleParaVender(lote, modo) > 0) i,
  ];
  if (candidatos.isEmpty) return null;
  return candidatos.reduce((a, b) {
    final loteA = producto.lotes[a];
    final loteB = producto.lotes[b];
    if (modo == ModoVenta.porPeso && loteA.piezaAbierta != loteB.piezaAbierta) {
      return loteA.piezaAbierta ? a : b;
    }
    return loteB.cantidad > loteA.cantidad ? b : a;
  });
}
