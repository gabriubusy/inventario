import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';

/// What arrived of one line, by its place on the invoice.
typedef Llegada = ({int indice, int piezas, int cantidad});

/// The order's lines with every [llegadas] entry confirmed; the others
/// keep waiting. An entry with nothing in it, pointing nowhere or on a
/// line already received is ignored.
List<LineaCompra> conLlegadas(Compra compra, List<Llegada> llegadas) {
  final lineas = [...compra.lineas];
  for (final llegada in llegadas) {
    if (llegada.indice < 0 || llegada.indice >= lineas.length) continue;
    final linea = lineas[llegada.indice];
    if (linea.recibida || (llegada.cantidad <= 0 && llegada.piezas <= 0)) {
      continue;
    }
    lineas[llegada.indice] = linea.conRecibido(
      piezas: llegada.piezas,
      cantidad: llegada.cantidad,
    );
  }
  return lineas;
}

/// Which lines of [compra] would be confirmed by [llegadas].
List<int> indicesDeLlegadas(Compra compra, List<Llegada> llegadas) {
  final lineas = conLlegadas(compra, llegadas);
  return [
    for (final (i, linea) in lineas.indexed)
      if (linea.recibida && !compra.lineas[i].recibida) i,
  ];
}
