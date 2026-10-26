import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

/// Asks for an image file; null when the user cancels.
typedef ElegirImagen = Future<Uint8List?> Function();

const _imagenes = XTypeGroup(
  label: 'Imágenes',
  extensions: ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'],
);

/// Opens the system file picker.
Future<Uint8List?> elegirImagenDelEquipo() async {
  final archivo = await openFile(acceptedTypeGroups: [_imagenes]);
  return archivo?.readAsBytes();
}
