import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:inventario/features/productos/data/procesar_imagen.dart';
import 'package:inventario/features/productos/domain/almacen_imagenes.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_imagen.dart';
import 'package:inventario/features/productos/domain/tamano_imagen.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps each photo as JPEG files in the app folder. Desktop only, not web.
class AlmacenImagenesArchivos implements AlmacenImagenes {
  AlmacenImagenesArchivos(this._carpeta, {Random? azar})
    : _azar = azar ?? Random.secure();

  static Future<AlmacenImagenesArchivos> enCarpetaDeLaApp() async {
    final soporte = await getApplicationSupportDirectory();
    return AlmacenImagenesArchivos(
      Directory('${soporte.path}${Platform.pathSeparator}imagenes'),
    );
  }

  static final _formatoId = RegExp(r'^[0-9a-f]{32}$');

  final Directory _carpeta;
  final Random _azar;

  @override
  Future<ResultadoGuardarImagen> guardar(Uint8List bytes) async {
    // Decoding a phone photo is slow enough to freeze the UI thread.
    final versiones = await Isolate.run(() => procesarImagen(bytes));
    if (versiones == null) return const ImagenNoValida();
    await _carpeta.create(recursive: true);
    final id = _nuevoId();
    for (final MapEntry(key: tamano, value: datos) in versiones.entries) {
      await _archivo(id, tamano).writeAsBytes(datos, flush: true);
    }
    return ImagenGuardada(id);
  }

  @override
  Future<Uint8List?> leer(String id, TamanoImagen tamano) async {
    if (!_formatoId.hasMatch(id)) return null;
    try {
      return await _archivo(id, tamano).readAsBytes();
    } on PathNotFoundException {
      return null;
    }
  }

  @override
  Future<void> borrar(String id) async {
    if (!_formatoId.hasMatch(id)) return;
    for (final tamano in TamanoImagen.values) {
      final archivo = _archivo(id, tamano);
      if (await archivo.exists()) await archivo.delete();
    }
  }

  File _archivo(String id, TamanoImagen tamano) {
    final sufijo = switch (tamano) {
      TamanoImagen.completa => '',
      TamanoImagen.miniatura => '_mini',
    };
    return File('${_carpeta.path}${Platform.pathSeparator}$id$sufijo.jpg');
  }

  String _nuevoId() => List.generate(
    16,
    (_) => _azar.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
