import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/precio_en_lista.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';

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

  /// Dollar hundredths for [escrito] at [precio] (per unit, or per pack);
  /// null when there is no price.
  int? importe(int escrito, int? precio);

  /// The price [importe] uses: the lot's per unit, or the pack's, in [lista].
  int? precio(Producto producto, LoteMarca lote, ListaPrecio lista);

  /// The unit typed, so "250 g" can be read too; null for packs.
  UnidadBase? get unidadEscrita;
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
  int? importe(int escrito, int? precio) => precio == null
      ? null
      : dividirRedondeando(precio * escrito, unidad.fraccionesPorUnidad);

  @override
  int? precio(Producto producto, LoteMarca lote, ListaPrecio lista) =>
      precioDeLote(producto, lote, lista);

  @override
  UnidadBase get unidadEscrita => unidad;
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
  int? importe(int escrito, int? precio) =>
      precio == null ? null : dividirRedondeando(escrito * precio, _escala);

  @override
  int? precio(Producto producto, LoteMarca lote, ListaPrecio lista) =>
      precioDePresentacion(producto, presentacion, lote, lista);

  @override
  UnidadBase? get unidadEscrita => null;
}
