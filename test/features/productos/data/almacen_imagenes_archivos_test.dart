import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:inventario/features/productos/data/almacen_imagenes_archivos.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_imagen.dart';
import 'package:inventario/features/productos/domain/tamano_imagen.dart';

void main() {
  late Directory carpeta;
  late AlmacenImagenesArchivos almacen;
  final foto = img.encodePng(img.Image(width: 1000, height: 500));

  setUp(() async {
    carpeta = await Directory.systemTemp.createTemp('imagenes_test');
    almacen = AlmacenImagenesArchivos(carpeta);
  });

  tearDown(() => carpeta.delete(recursive: true));

  Future<String> guardar() async =>
      (await almacen.guardar(foto) as ImagenGuardada).id;

  test('saves both sizes and reads them back', () async {
    final id = await guardar();
    final completa = await almacen.leer(id, TamanoImagen.completa);
    final miniatura = await almacen.leer(id, TamanoImagen.miniatura);
    expect(img.decodeJpg(completa!)!.width, 800);
    expect(img.decodeJpg(miniatura!)!.width, 200);
  });

  test('gives every photo its own id', () async {
    expect(await guardar(), isNot(await guardar()));
  });

  test('rejects an invalid image without writing files', () async {
    final resultado = await almacen.guardar(Uint8List.fromList([0, 1, 2]));
    expect(resultado, isA<ImagenNoValida>());
    expect(carpeta.listSync(), isEmpty);
  });

  test('deleting removes every size', () async {
    final id = await guardar();
    await almacen.borrar(id);
    expect(await almacen.leer(id, TamanoImagen.completa), isNull);
    expect(carpeta.listSync(), isEmpty);
  });

  test('reads nothing for an unknown id', () async {
    expect(await almacen.leer('0' * 32, TamanoImagen.completa), isNull);
  });

  test('ignores ids that try to leave the folder', () async {
    expect(await almacen.leer(r'..\secreto', TamanoImagen.completa), isNull);
  });
}
