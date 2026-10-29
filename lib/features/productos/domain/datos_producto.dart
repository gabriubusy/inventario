import 'package:inventario/core/listas.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/regla_precio.dart';

/// What the user fills in to create or edit a product; already validated.
class DatosProducto {
  const DatosProducto({
    required this.nombre,
    required this.categoria,
    required this.forma,
    required this.minimo,
    this.lotes = const [],
    this.presentaciones = const [],
    this.imagenId,
    this.reglas = const {},
  });

  /// The current values, e.g. to undo an edit.
  DatosProducto.desde(Producto producto)
    : this(
        nombre: producto.nombre,
        categoria: producto.categoria,
        forma: producto.forma,
        minimo: producto.minimo,
        lotes: producto.lotes,
        presentaciones: producto.presentaciones,
        imagenId: producto.imagenId,
        reglas: producto.reglas,
      );

  final String nombre;
  final Categoria categoria;
  final FormaConteo forma;

  /// Scaled like [Producto.minimo].
  final int minimo;

  /// Stock in the shop, one entry per brand and supplier.
  final List<LoteMarca> lotes;

  final List<Presentacion> presentaciones;

  final String? imagenId;

  /// Mayor and Especial rules, like [Producto.reglas].
  final Map<ListaPrecio, ReglaPrecio> reglas;

  @override
  bool operator ==(Object other) =>
      other is DatosProducto &&
      other.nombre == nombre &&
      other.categoria == categoria &&
      other.forma == forma &&
      other.minimo == minimo &&
      other.imagenId == imagenId &&
      listasIguales(other.lotes, lotes) &&
      listasIguales(other.presentaciones, presentaciones) &&
      mapasIguales(other.reglas, reglas);

  @override
  int get hashCode => Object.hash(
    nombre,
    categoria,
    forma,
    minimo,
    imagenId,
    Object.hashAll(lotes),
    Object.hashAll(presentaciones),
    hashDeMapa(reglas),
  );
}
