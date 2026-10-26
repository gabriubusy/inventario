import 'dart:typed_data';

import 'package:inventario/features/productos/domain/almacen_imagenes.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_imagen.dart';
import 'package:inventario/features/productos/domain/tamano_imagen.dart';

/// Product photos, with each read kept so lists don't hit the disk on scroll.
class GestorFotos {
  GestorFotos(this._almacen);

  final AlmacenImagenes _almacen;
  final _leidas = <(String, TamanoImagen), Future<Uint8List?>>{};

  Future<ResultadoGuardarImagen> guardar(Uint8List bytes) =>
      _almacen.guardar(bytes);

  Future<Uint8List?> leer(String id, TamanoImagen tamano) =>
      _leidas.putIfAbsent((id, tamano), () => _almacen.leer(id, tamano));

  /// Once an edit can no longer be undone, the photo left out is deleted:
  /// the replaced one, or the new one if the edit was undone.
  Future<void> soltarSustituida({
    required String? anterior,
    required String? actual,
    required bool deshecho,
  }) async {
    if (anterior == actual) return;
    await borrar(deshecho ? actual : anterior);
  }

  /// Does nothing for null, so callers can pass an optional id.
  Future<void> borrar(String? id) async {
    if (id == null) return;
    _leidas.removeWhere((clave, _) => clave.$1 == id);
    await _almacen.borrar(id);
  }
}
