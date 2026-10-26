import 'package:inventario/core/listas.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';

typedef RangoPrecio = ({int minimo, int maximo});

class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.forma,
    required this.minimo,
    this.lotes = const [],
    this.imagenId,
  });

  final String id;
  final String nombre;
  final Categoria categoria;
  final FormaConteo forma;

  /// Compared with [medida]: pieces, or the quantity in [FormaConteo.unidad].
  final int minimo;
  final List<LoteMarca> lotes;

  /// Photo in the image store; null when the product has none.
  final String? imagenId;

  int get piezas => lotes.fold(0, (total, lote) => total + lote.piezas);

  int get piezasAbiertas => lotes.where((lote) => lote.piezaAbierta).length;

  /// Total quantity across brands, scaled like [LoteMarca.cantidad].
  int get cantidad => lotes.fold(0, (total, lote) => total + lote.cantidad);

  /// What the minimum is measured against.
  int get medida => forma.cuentaPiezas ? piezas + piezasAbiertas : cantidad;

  /// The way of counting can't change while there is stock measured with it.
  bool get tieneExistencias => lotes.any((lote) => lote.tieneExistencia);

  /// Cheapest and dearest brand price; null when no brand has one.
  RangoPrecio? get rangoPrecio {
    final precios = [for (final lote in lotes) ?lote.precio];
    if (precios.isEmpty) return null;
    return (
      minimo: precios.reduce((a, b) => a < b ? a : b),
      maximo: precios.reduce((a, b) => a > b ? a : b),
    );
  }

  EstadoStock get estado {
    if (medida <= 0) return EstadoStock.agotado;
    if (medida < minimo) return EstadoStock.bajo;
    return EstadoStock.disponible;
  }

  /// [imagenId] is kept; build a new [Producto] to remove the photo.
  Producto copyWith({
    String? id,
    String? nombre,
    Categoria? categoria,
    FormaConteo? forma,
    int? minimo,
    List<LoteMarca>? lotes,
    String? imagenId,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      forma: forma ?? this.forma,
      minimo: minimo ?? this.minimo,
      lotes: lotes ?? this.lotes,
      imagenId: imagenId ?? this.imagenId,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Producto &&
      other.id == id &&
      other.nombre == nombre &&
      other.categoria == categoria &&
      other.forma == forma &&
      other.minimo == minimo &&
      other.imagenId == imagenId &&
      listasIguales(other.lotes, lotes);

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    categoria,
    forma,
    minimo,
    imagenId,
    Object.hashAll(lotes),
  );
}
