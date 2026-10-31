import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/regla_precio.dart';

const _cien = 10000;

/// Lowering by this much or more would leave prices at zero or below.
const bajadaImposible = -_cien;

/// Raises (or lowers, when negative) [lista]'s prices of [producto] by
/// [porcentaje] hundredths of a percent. Detal moves each brand's price for
/// which [lote] holds, and each pack's when [presentaciones]; Mayor and
/// Especial move their rule so the result moves by the same share. A list
/// without a rule is left alone (it follows Detal).
Producto ajustarPrecios(
  Producto producto,
  ListaPrecio lista,
  int porcentaje, {
  bool Function(LoteMarca lote)? lote,
  bool presentaciones = true,
}) {
  if (porcentaje <= bajadaImposible) return producto;
  int subir(int valor) =>
      dividirRedondeando(valor * (_cien + porcentaje), _cien);
  if (lista == ListaPrecio.detal) {
    return producto.copyWith(
      lotes: [
        for (final l in producto.lotes)
          switch (l.precio) {
            final precio? when lote?.call(l) ?? true => l.copyWith(
              precio: subir(precio),
            ),
            _ => l,
          },
      ],
      presentaciones: [
        for (final p in producto.presentaciones)
          presentaciones ? p.copyWith(precio: subir(p.precio)) : p,
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
