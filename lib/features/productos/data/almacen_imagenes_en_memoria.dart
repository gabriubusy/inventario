import 'dart:typed_data';

import 'package:inventario/features/productos/domain/almacen_imagenes.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_imagen.dart';
import 'package:inventario/features/productos/domain/tamano_imagen.dart';

/// Keeps the bytes untouched for every size; meant for tests.
class AlmacenImagenesEnMemoria implements AlmacenImagenes {
  final _imagenes = <String, Uint8List>{};
  var _siguienteId = 1;

  @override
  Future<ResultadoGuardarImagen> guardar(Uint8List bytes) async {
    if (bytes.isEmpty) return const ImagenNoValida();
    final id = '${_siguienteId++}';
    _imagenes[id] = bytes;
    return ImagenGuardada(id);
  }

  @override
  Future<Uint8List?> leer(String id, TamanoImagen tamano) async =>
      _imagenes[id];

  @override
  Future<void> borrar(String id) async => _imagenes.remove(id);
}
