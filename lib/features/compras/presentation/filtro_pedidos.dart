import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/estado_pedido.dart';

/// Which orders the list shows; Alt+1… picks one.
enum FiltroPedidos {
  pendientes('Pendientes'),
  parciales('Parciales'),
  recibidos('Recibidos'),
  todos('Todos');

  const FiltroPedidos(this.etiqueta);

  final String etiqueta;

  bool acepta(Compra compra) => switch (this) {
    pendientes => compra.estado == EstadoPedido.pendiente,
    parciales => compra.estado == EstadoPedido.parcial,
    recibidos => !compra.estado.esperando,
    todos => true,
  };
}
