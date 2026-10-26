import 'package:inventario/features/tasa/domain/tasa_cambio.dart';

/// Keeps only the latest rate; an older one still prices until replaced.
abstract interface class AlmacenTasa {
  Future<TasaCambio?> leer();
  Future<void> guardar(TasaCambio tasa);
}
