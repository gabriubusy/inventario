import 'dart:typed_data';

import 'package:inventario/features/productos/domain/resultado_guardar_imagen.dart';
import 'package:inventario/features/productos/domain/tamano_imagen.dart';

/// Photos live outside the database; a product keeps only the id.
abstract interface class AlmacenImagenes {
  Future<ResultadoGuardarImagen> guardar(Uint8List bytes);
  Future<Uint8List?> leer(String id, TamanoImagen tamano);
  Future<void> borrar(String id);
}
