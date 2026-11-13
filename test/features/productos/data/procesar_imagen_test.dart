import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:inventario/features/productos/data/procesar_imagen.dart';
import 'package:inventario/features/productos/domain/tamano_imagen.dart';

Uint8List _png(int ancho, int alto, {bool transparente = false}) {
  final imagen = img.Image(
    width: ancho,
    height: alto,
    numChannels: transparente ? 4 : 3,
  );
  if (!transparente) img.fill(imagen, color: img.ColorRgb8(200, 30, 40));
  return img.encodePng(imagen);
}

img.Image _decodificar(Uint8List bytes) => img.decodeJpg(bytes)!;

void main() {
  test('shrinks a landscape photo keeping its proportions', () {
    final versiones = procesarImagen(_png(1600, 1200))!;
    final completa = _decodificar(versiones[TamanoImagen.completa]!);
    final miniatura = _decodificar(versiones[TamanoImagen.miniatura]!);
    expect((completa.width, completa.height), (800, 600));
    expect((miniatura.width, miniatura.height), (200, 150));
  });

  test('limits the height of a portrait photo', () {
    final versiones = procesarImagen(_png(1200, 1600))!;
    final completa = _decodificar(versiones[TamanoImagen.completa]!);
    expect((completa.width, completa.height), (600, 800));
  });

  test('never enlarges a small photo', () {
    final versiones = procesarImagen(_png(120, 90))!;
    final completa = _decodificar(versiones[TamanoImagen.completa]!);
    expect((completa.width, completa.height), (120, 90));
  });

  test('puts transparent areas on white instead of black', () {
    final versiones = procesarImagen(_png(50, 50, transparente: true))!;
    final pixel = _decodificar(versiones[TamanoImagen.completa]!)
        .getPixel(25, 25);
    expect(pixel.r, greaterThan(240));
  });

  test('rejects bytes that are not an image', () {
    expect(procesarImagen(Uint8List.fromList([1, 2, 3, 4])), isNull);
  });

  test('a photo cut in half is refused, not thrown', () {
    final entera = _png(1600, 1200);
    final cortada = Uint8List.sublistView(entera, 0, entera.length ~/ 3);
    expect(procesarImagen(cortada), isNull);
  });

  test('a header that lies about its size is refused', () {
    final bytes = Uint8List.fromList(_png(40, 40));
    // The width and height live right after the PNG signature.
    bytes.setRange(16, 24, [0, 0, 255, 255, 0, 0, 255, 255]);
    expect(procesarImagen(bytes), isNull);
  });
}
