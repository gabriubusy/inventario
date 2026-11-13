import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/recepcion.dart';

/// What a reception would leave behind, to show before saving it.
class ResumenRecepcion {
  const ResumenRecepcion({
    required this.lineas,
    required this.valor,
    required this.diferencia,
    required this.conDiferencia,
  });

  factory ResumenRecepcion.de(Compra compra, List<Llegada> llegadas) {
    final confirmadas = conLlegadas(compra, llegadas);
    var valor = 0;
    var pedido = 0;
    var conDiferencia = 0;
    final indices = indicesDeLlegadas(compra, llegadas);
    for (final i in indices) {
      valor += confirmadas[i].subtotalRecibido;
      pedido += confirmadas[i].subtotal;
      if (confirmadas[i].tieneDiferencia) conDiferencia++;
    }
    return ResumenRecepcion(
      lineas: indices.length,
      valor: valor,
      diferencia: valor - pedido,
      conDiferencia: conDiferencia,
    );
  }

  /// How many lines would enter the stock.
  final int lineas;

  /// Their value at the invoice's cost, in dollar hundredths.
  final int valor;

  /// More (or less) than those lines' part of the invoice.
  final int diferencia;
  final int conDiferencia;

  bool get vacia => lineas == 0;
}
