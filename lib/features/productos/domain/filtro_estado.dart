import 'package:inventario/features/productos/domain/estado_stock.dart';

/// Quick filter of the products screen.
enum FiltroEstado {
  todos('Todos'),
  bajo('Stock bajo'),
  agotados('Agotados');

  const FiltroEstado(this.etiqueta);

  final String etiqueta;

  bool admite(EstadoStock estado) => switch (this) {
    FiltroEstado.todos => true,
    FiltroEstado.bajo => estado == EstadoStock.bajo,
    FiltroEstado.agotados => estado == EstadoStock.agotado,
  };
}
