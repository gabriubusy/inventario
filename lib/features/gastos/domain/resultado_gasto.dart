import 'package:inventario/features/gastos/domain/gasto.dart';

sealed class ResultadoGasto {
  const ResultadoGasto();
}

class GastoRegistrado extends ResultadoGasto {
  const GastoRegistrado(this.gasto);

  final Gasto gasto;
}

/// An amount in bolívares without today's rate: the reports could not
/// count it in dollars, so nothing is stored.
class GastoSinTasa extends ResultadoGasto {
  const GastoSinTasa();
}
