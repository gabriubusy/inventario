import 'package:inventario/features/salidas/domain/linea_ticket.dart';
import 'package:inventario/features/salidas/domain/venta.dart';

sealed class ResultadoCobro {
  const ResultadoCobro();
}

class VentaCobrada extends ResultadoCobro {
  const VentaCobrada(this.venta);

  final Venta venta;
}

/// The stock changed since the line was added and no longer covers it.
class CobroSinExistencias extends ResultadoCobro {
  const CobroSinExistencias(this.linea);

  final LineaTicket linea;
}

/// Payments don't reach the total, or pay too much without cash.
class CobroIncompleto extends ResultadoCobro {
  const CobroIncompleto();
}

/// Nothing is sold without today's rate.
class CobroSinTasa extends ResultadoCobro {
  const CobroSinTasa();
}
