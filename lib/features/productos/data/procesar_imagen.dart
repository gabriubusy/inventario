import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:inventario/features/productos/domain/tamano_imagen.dart';

/// Shrinks a photo to every [TamanoImagen] as JPEG; null if it can't be read.
Map<TamanoImagen, Uint8List>? procesarImagen(Uint8List bytes) {
  final img.Image? original;
  try {
    original = img.decodeImage(bytes);
  } on img.ImageException {
    return null;
  }
  if (original == null) return null;
  // Phone photos store rotation in EXIF, which JPEG re-encoding drops.
  final orientada = img.bakeOrientation(original);
  return {
    for (final tamano in TamanoImagen.values)
      tamano: img.encodeJpg(
        _sobreBlanco(_reducir(orientada, tamano.ladoMaximo)),
        quality: _calidad(tamano),
      ),
  };
}

int _calidad(TamanoImagen tamano) => switch (tamano) {
  TamanoImagen.completa => 82,
  TamanoImagen.miniatura => 75,
};

img.Image _reducir(img.Image imagen, int ladoMaximo) {
  if (imagen.width <= ladoMaximo && imagen.height <= ladoMaximo) return imagen;
  return imagen.width >= imagen.height
      ? img.copyResize(
          imagen,
          width: ladoMaximo,
          interpolation: img.Interpolation.average,
        )
      : img.copyResize(
          imagen,
          height: ladoMaximo,
          interpolation: img.Interpolation.average,
        );
}

/// JPEG has no transparency; without this, transparent PNGs turn black.
img.Image _sobreBlanco(img.Image imagen) {
  if (!imagen.hasAlpha) return imagen;
  final fondo = img.Image(width: imagen.width, height: imagen.height)
    ..clear(img.ColorRgb8(255, 255, 255));
  return img.compositeImage(fondo, imagen);
}
