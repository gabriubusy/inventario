import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/motivo_devolucion.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/sacar_de_lote.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// The incident's goods as a return line, valued at its lot's cost (0 when
/// the lot has none).
List<LineaCompra> lineasDeIncidencia(
  Incidencia incidencia,
  List<Producto> productos,
) {
  final producto = productos.where((p) => p.id == incidencia.productoId);
  int? costo;
  if (producto.isNotEmpty) {
    final indice = indiceLote(
      producto.first,
      incidencia.marca,
      incidencia.proveedor,
    );
    if (indice != -1) costo = producto.first.lotes[indice].costo;
  }
  return [
    LineaCompra(
      productoId: incidencia.productoId,
      producto: incidencia.producto,
      forma: incidencia.forma,
      marca: incidencia.marca,
      piezas: incidencia.piezas,
      cantidad: incidencia.cantidad,
      costo: costo ?? 0,
    ),
  ];
}

/// The reason that matches what the incident says went wrong.
MotivoDevolucion motivoDeIncidencia(Incidencia? incidencia) =>
    switch (incidencia?.tipo) {
      TipoIncidencia.vencido => MotivoDevolucion.vencido,
      TipoIncidencia.equivocado => MotivoDevolucion.noPedido,
      TipoIncidencia.otro || TipoIncidencia.faltante => MotivoDevolucion.otro,
      TipoIncidencia.malEstado || null => MotivoDevolucion.danado,
    };
