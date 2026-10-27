/// What went wrong with goods from a supplier.
enum TipoIncidencia {
  malEstado('Llegó en mal estado', sacaDelInventario: true),
  vencido('Vencido o por vencer', sacaDelInventario: true),
  // Usually the entry was already typed with what really arrived.
  faltante('Faltó peso o piezas', sacaDelInventario: false),
  equivocado('Producto equivocado', sacaDelInventario: true),
  otro('Otro', sacaDelInventario: true);

  const TipoIncidencia(this.etiqueta, {required this.sacaDelInventario});

  final String etiqueta;

  /// Whether "Sacar del inventario" starts ticked for this kind.
  final bool sacaDelInventario;
}
