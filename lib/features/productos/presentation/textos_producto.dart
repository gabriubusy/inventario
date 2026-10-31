import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/productos/domain/desglose_stock.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';

String textoPiezas(int piezas) =>
    piezas == 1 ? '1 pieza' : '${formatDecimal(piezas, decimales: 0)} piezas';

/// The big figure on a card: pieces, or the quantity for other products.
String textoPrincipal(Producto producto) => producto.forma.cuentaPiezas
    ? textoPiezas(producto.piezas)
    : producto.forma.unidad.formatear(producto.cantidad);

/// "(1 saco + 11,5 kg)" next to the total; null when no pack fits.
String? textoDesglose(Producto producto) {
  final desglose = desglosarStock(producto);
  if (desglose == null) return null;
  final paquetes = textoPaquetes(desglose.presentacion, desglose.paquetes);
  if (desglose.resto == 0) return '($paquetes)';
  return '($paquetes + ${producto.forma.unidad.formatear(desglose.resto)})';
}

/// The total with its breakdown: "26,5 kg (1 saco + 11,5 kg)".
String textoStock(Producto producto) {
  final desglose = textoDesglose(producto);
  final total = textoPrincipal(producto);
  return desglose == null ? total : '$total $desglose';
}

/// "1 saco", "3 sacos", "2 sacos 15 kg", formatted like any other quantity.
String textoPaquetes(Presentacion presentacion, int paquetes) {
  final nombre = presentacion.nombre.trim().toLowerCase();
  // Only the first word takes the plural: "saco 15 kg" → "sacos 15 kg".
  final espacio = nombre.indexOf(' ');
  final palabra = espacio == -1 ? nombre : nombre.substring(0, espacio);
  final resto = espacio == -1 ? '' : nombre.substring(espacio);
  final plural = RegExp('[aeiouáéíóú]\$').hasMatch(palabra)
      ? '${palabra}s'
      : '${palabra}es';
  return '${formatDecimal(paquetes, decimales: 0)} '
      '${paquetes == 1 ? nombre : '$plural$resto'}';
}

/// Total weight and average per piece; null for products without pieces.
String? textoPeso(Producto producto) {
  if (!producto.forma.cuentaPiezas) return null;
  final unidad = producto.forma.unidad;
  final peso = '${unidad.formatear(producto.cantidad)} en total';
  final promedio = textoPromedioPorPieza(
    producto.cantidad,
    producto.piezas + producto.piezasAbiertas,
    unidad,
  );
  return promedio == null ? peso : '$peso · $promedio';
}

/// "≈ 0,8 kg por pieza"; null when there are no pieces to divide by.
String? textoPromedioPorPieza(int cantidad, int piezas, UnidadBase unidad) {
  if (piezas <= 0) return null;
  // Rounded to 10 g: enough to tell pieces apart at a glance.
  final promedio = dividirRedondeando(cantidad, piezas * 10) * 10;
  return '≈ ${unidad.formatear(promedio)} por pieza';
}

/// "Marca A: 10 · Marca B: 14 + 1 abierta"; null when there is no stock.
String? textoMarcas(Producto producto) {
  if (producto.lotes.isEmpty) return null;
  return [
    for (final lote in producto.lotes)
      '${lote.marca}: ${_cantidadLote(producto, lote)}',
  ].join(' · ');
}

/// Full stock of one lot: "10 piezas · 8,2 kg", "3 piezas + 1 abierta · 16,4 kg", "12 l".
String textoLote(Producto producto, LoteMarca lote) =>
    textoLoteSegun(producto.forma, lote);

String textoLoteSegun(FormaConteo forma, LoteMarca lote) {
  final cantidad = forma.unidad.formatear(lote.cantidad);
  if (!forma.cuentaPiezas) return cantidad;
  final abierta = lote.piezaAbierta ? ' + 1 abierta' : '';
  return '${textoPiezas(lote.piezas)}$abierta · $cantidad';
}

String textoMinimo(Producto producto) =>
    'mín. ${textoCantidadMinima(producto)}';

/// The minimum alone, in pieces or in the product's unit.
String textoCantidadMinima(Producto producto) => producto.forma.cuentaPiezas
    ? textoPiezas(producto.minimo)
    : producto.forma.unidad.formatear(producto.minimo);

/// "$ 9,80 /kg", or "$ 5,20–5,60 /kg" when brands differ; null without prices.
String? textoPrecio(Producto producto) {
  final rango = producto.rangoPrecio;
  if (rango == null) return null;
  final unidad = '/${producto.forma.unidad.simbolo}';
  if (rango.minimo == rango.maximo) {
    return '${formatearDolares(rango.minimo)} $unidad';
  }
  return '${formatearDolares(rango.minimo)}–${_cifra(rango.maximo)} $unidad';
}

/// The same price in bolívares; null without a price or a rate.
String? textoPrecioBs(Producto producto, int? Function(int) aBolivares) {
  final rango = producto.rangoPrecio;
  if (rango == null) return null;
  final minimo = aBolivares(rango.minimo);
  final maximo = aBolivares(rango.maximo);
  if (minimo == null || maximo == null) return null;
  if (minimo == maximo) return formatearBolivares(minimo);
  return '${_cifra(minimo)}–${formatearBolivares(maximo)}';
}

/// "9 productos · 2 con stock bajo · 1 agotado"
String resumenProductos(List<Producto> productos) {
  final total = productos.length;
  final bajos = productos.where((p) => p.estado == EstadoStock.bajo).length;
  final agotados = productos
      .where((p) => p.estado == EstadoStock.agotado)
      .length;
  return [
    '$total ${total == 1 ? 'producto' : 'productos'}',
    if (bajos > 0) '$bajos con stock bajo',
    if (agotados > 0) '$agotados ${agotados == 1 ? 'agotado' : 'agotados'}',
  ].join(' · ');
}

String _cifra(int centimos) => formatDecimal(
  centimos,
  decimales: decimalesDinero,
  minDecimales: decimalesDinero,
);

String _cantidadLote(Producto producto, LoteMarca lote) {
  if (!producto.forma.cuentaPiezas) {
    return producto.forma.unidad.formatear(lote.cantidad);
  }
  final piezas = formatDecimal(lote.piezas, decimales: 0);
  return lote.piezaAbierta ? '$piezas + 1 abierta' : piezas;
}
