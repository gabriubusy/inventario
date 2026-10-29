import 'package:inventario/core/listas.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/domain/linea_ticket.dart';
import 'package:inventario/features/salidas/domain/vender.dart';

/// The products of one customer's sale, in the order they were rung up,
/// all priced in one [lista]. Stock only changes when it is paid, but every
/// line must fit what is left after the lines before it.
class Ticket {
  const Ticket([this.lineas = const [], this.lista = ListaPrecio.detal]);

  final List<LineaTicket> lineas;
  final ListaPrecio lista;

  bool get vacio => lineas.isEmpty;

  /// Dollar hundredths; lines without a price add nothing.
  int get total => lineas.fold(0, (suma, l) => suma + (l.importe ?? 0));

  /// The product as it would be once the lines already here are sold; null
  /// when the stock no longer covers them (it changed meanwhile).
  Producto? aplicado(Producto producto) {
    Producto? resultado = producto;
    for (final linea in lineas) {
      if (linea.productoId != producto.id) continue;
      resultado = resultado == null ? null : vender(resultado, linea.salida);
    }
    return resultado;
  }

  /// Null when [producto], after the lines already here, can't cover it.
  Ticket? agregar(Producto producto, LineaTicket linea) {
    final antes = aplicado(producto);
    if (antes == null || vender(antes, linea.salida) == null) return null;
    return Ticket([...lineas, linea], lista);
  }

  Ticket sin(int indice) => Ticket([
    for (final (i, linea) in lineas.indexed)
      if (i != indice) linea,
  ], lista);

  /// Puts back a line taken out, where it was.
  Ticket con(int indice, LineaTicket linea) =>
      Ticket([...lineas]..insert(indice.clamp(0, lineas.length), linea), lista);

  /// The same lines priced in [nueva]; a line whose product or brand is
  /// gone keeps its amount.
  Ticket conLista(ListaPrecio nueva, Producto? Function(String id) buscar) =>
      Ticket([
        for (final linea in lineas)
          switch (buscar(linea.productoId)) {
            null => linea,
            final producto => switch (indiceLoteDeSalida(
              producto,
              linea.salida,
            )) {
              -1 => linea,
              final indice => linea.conImporte(
                importeDeSalida(
                  producto,
                  producto.lotes[indice],
                  linea.salida.cantidad,
                  presentacion: linea.salida.presentacion,
                  lista: nueva,
                ),
              ),
            },
          },
      ], nueva);

  @override
  bool operator ==(Object other) =>
      other is Ticket &&
      other.lista == lista &&
      listasIguales(other.lineas, lineas);

  @override
  int get hashCode => Object.hash(lista, Object.hashAll(lineas));
}
