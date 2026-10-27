import 'package:inventario/features/caja/domain/caja.dart';

abstract interface class RepositorioCajas {
  Future<List<Caja>> obtenerTodas();

  /// Stores a newly opened till and returns it with its id.
  Future<Caja> abrir(Caja caja);

  /// Saves the closing count of [caja].
  Future<void> cerrar(Caja caja);
}
