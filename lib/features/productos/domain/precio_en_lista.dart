import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/regla_precio.dart';

const _cien = 10000;

/// Dollar hundredths per kg, l or und of [lote] in [lista]; null when the
/// brand has no Detal price and the rule can't give one.
int? precioDeLote(Producto producto, LoteMarca lote, ListaPrecio lista) =>
    switch (_regla(producto, lista)) {
      null => lote.precio,
      PrecioFijo(:final precio) => precio,
      MargenSobreCosto(:final porcentaje) => switch (lote.costo) {
        null => lote.precio,
        final costo => dividirRedondeando(costo * (_cien + porcentaje), _cien),
      },
    };

/// The price of one [presentacion] in [lista]. A rule is applied to the
/// pack's size: a fixed price per kg times its kilos, or [lote]'s cost of
/// those kilos plus the profit.
int precioDePresentacion(
  Producto producto,
  Presentacion presentacion,
  LoteMarca? lote,
  ListaPrecio lista,
) {
  final fracciones = producto.forma.unidad.fraccionesPorUnidad;
  return switch (_regla(producto, lista)) {
    null => presentacion.precio,
    PrecioFijo(:final precio) => dividirRedondeando(
      precio * presentacion.factor,
      fracciones,
    ),
    MargenSobreCosto(:final porcentaje) => switch (lote?.costo) {
      null => presentacion.precio,
      final costo => dividirRedondeando(
        costo * presentacion.factor * (_cien + porcentaje),
        fracciones * _cien,
      ),
    },
  };
}

ReglaPrecio? _regla(Producto producto, ListaPrecio lista) =>
    lista == ListaPrecio.detal ? null : producto.reglas[lista];
