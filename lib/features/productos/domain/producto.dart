import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';

class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.unidad,
    required this.existencia,
    required this.minimo,
  });

  final String id;
  final String nombre;
  final Categoria categoria;
  final UnidadBase unidad;

  /// Stock and minimum in [UnidadBase.fraccionesPorUnidad] (grams for kg).
  final int existencia;
  final int minimo;

  EstadoStock get estado {
    if (existencia <= 0) return EstadoStock.agotado;
    if (existencia < minimo) return EstadoStock.bajo;
    return EstadoStock.disponible;
  }

  Producto copyWith({
    String? id,
    String? nombre,
    Categoria? categoria,
    UnidadBase? unidad,
    int? existencia,
    int? minimo,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      unidad: unidad ?? this.unidad,
      existencia: existencia ?? this.existencia,
      minimo: minimo ?? this.minimo,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Producto &&
      other.id == id &&
      other.nombre == nombre &&
      other.categoria == categoria &&
      other.unidad == unidad &&
      other.existencia == existencia &&
      other.minimo == minimo;

  @override
  int get hashCode =>
      Object.hash(id, nombre, categoria, unidad, existencia, minimo);
}
