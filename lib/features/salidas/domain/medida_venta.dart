import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';

/// What the amount typed in a sale means: packs ("1,5 sacos") or the
/// product's own unit ("2,5 kg"), and how it turns into stock and money.
sealed class MedidaVenta {
  const MedidaVenta();

  /// Decimals the typed amount is scaled by.
  int get decimales;

  /// Stock it takes out, scaled like the lot's quantity.
  int aBase(int escrito);

  /// The most that can be typed with [base] in stock.
  int desdeBase(int base);

  /// Dollar hundredths; null when there is no price for it.
  int? importe(int escrito, LoteMarca lote);
}

/// Typed straight in kg, l or und; priced with the brand's price.
class MedidaEnUnidad extends MedidaVenta {
  const MedidaEnUnidad(this.unidad);

  final UnidadBase unidad;

  @override
  int get decimales => unidad.decimales;

  @override
  int aBase(int escrito) => escrito;

  @override
  int desdeBase(int base) => base;

  @override
  int? importe(int escrito, LoteMarca lote) {
    final precio = lote.precio;
    if (precio == null) return null;
    return dividirRedondeando(precio * escrito, unidad.fraccionesPorUnidad);
  }
}

/// Typed in packs, with up to three decimals; priced with the pack's price,
/// the same for every brand.
class MedidaEnPresentacion extends MedidaVenta {
  const MedidaEnPresentacion(this.presentacion);

  static const _escala = 1000;

  final Presentacion presentacion;

  @override
  int get decimales => 3;

  @override
  int aBase(int escrito) =>
      dividirRedondeando(escrito * presentacion.factor, _escala);

  @override
  int desdeBase(int base) => base * _escala ~/ presentacion.factor;

  @override
  int? importe(int escrito, LoteMarca lote) =>
      dividirRedondeando(escrito * presentacion.precio, _escala);
}
