import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/regla_precio.dart';

const _cien = 10000;

/// Raises (or lowers, when negative) [lista]'s prices of [producto] by
/// [porcentaje] hundredths of a percent. Detal moves each brand's price and
/// each pack's; Mayor and Especial move their rule so the result moves by
/// the same share. A list without a rule is left alone (it follows Detal).
Producto ajustarPrecios(Producto producto, ListaPrecio lista, int porcentaje) {
  int subir(int valor) =>
      dividirRedondeando(valor * (_cien + porcentaje), _cien);
  if (lista == ListaPrecio.detal) {
    return producto.copyWith(
      lotes: [
        for (final lote in producto.lotes)
          switch (lote.precio) {
            null => lote,
            final precio => lote.copyWith(precio: subir(precio)),
          },
      ],
      presentaciones: [
        for (final p in producto.presentaciones)
          p.copyWith(precio: subir(p.precio)),
      ],
    );
  }
  final regla = producto.reglas[lista];
  if (regla == null) return producto;
  final nueva = switch (regla) {
    PrecioFijo(:final precio) => PrecioFijo(subir(precio)),
    // Cost × (1 + m) × (1 + p) = cost × (1 + m'), so m' = (1+m)(1+p) − 1.
    MargenSobreCosto(porcentaje: final margen) => MargenSobreCosto(
      dividirRedondeando((_cien + margen) * (_cien + porcentaje), _cien) -
          _cien,
    ),
  };
  return producto.copyWith(reglas: {...producto.reglas, lista: nueva});
}
