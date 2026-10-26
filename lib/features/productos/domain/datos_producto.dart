import 'package:inventario/core/listas.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// What the user fills in to create or edit a product; already validated.
class DatosProducto {
  const DatosProducto({
    required this.nombre,
    required this.categoria,
    required this.forma,
    required this.minimo,
    this.lotes = const [],
    this.imagenId,
  });

  /// The current values, e.g. to undo an edit.
  DatosProducto.desde(Producto producto)
    : this(
        nombre: producto.nombre,
        categoria: producto.categoria,
        forma: producto.forma,
        minimo: producto.minimo,
        lotes: producto.lotes,
        imagenId: producto.imagenId,
      );

  final String nombre;
  final Categoria categoria;
  final FormaConteo forma;

  /// Scaled like [Producto.minimo].
  final int minimo;

  /// Stock in the shop, one entry per brand and supplier.
  final List<LoteMarca> lotes;

  final String? imagenId;

  @override
  bool operator ==(Object other) =>
      other is DatosProducto &&
      other.nombre == nombre &&
      other.categoria == categoria &&
      other.forma == forma &&
      other.minimo == minimo &&
      other.imagenId == imagenId &&
      listasIguales(other.lotes, lotes);

  @override
  int get hashCode => Object.hash(
    nombre,
    categoria,
    forma,
    minimo,
    imagenId,
    Object.hashAll(lotes),
  );
}
