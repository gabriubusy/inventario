import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/data/almacen_imagenes_en_memoria.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_imagen.dart';
import 'package:inventario/features/productos/domain/tamano_imagen.dart';

/// Counts reads to check the cache.
class _AlmacenContado extends AlmacenImagenesEnMemoria {
  int lecturas = 0;

  @override
  Future<Uint8List?> leer(String id, TamanoImagen tamano) {
    lecturas++;
    return super.leer(id, tamano);
  }
}

void main() {
  late _AlmacenContado almacen;
  late GestorFotos fotos;

  setUp(() {
    almacen = _AlmacenContado();
    fotos = GestorFotos(almacen);
  });

  Future<String> guardar() async =>
      (await fotos.guardar(Uint8List.fromList([1])) as ImagenGuardada).id;

  test('reads each photo from the store only once', () async {
    final id = await guardar();
    await fotos.leer(id, TamanoImagen.miniatura);
    await fotos.leer(id, TamanoImagen.miniatura);
    expect(almacen.lecturas, 1);
  });

  test('a deleted photo is no longer served from the cache', () async {
    final id = await guardar();
    await fotos.leer(id, TamanoImagen.miniatura);
    await fotos.borrar(id);
    expect(await fotos.leer(id, TamanoImagen.miniatura), isNull);
  });

  test('after an edit, deletes the photo that was replaced', () async {
    final anterior = await guardar();
    final actual = await guardar();
    await fotos.soltarSustituida(
      anterior: anterior,
      actual: actual,
      deshecho: false,
    );
    expect(await almacen.leer(anterior, TamanoImagen.completa), isNull);
    expect(await almacen.leer(actual, TamanoImagen.completa), isNotNull);
  });

  test('after an undo, deletes the new photo and keeps the old one', () async {
    final anterior = await guardar();
    final actual = await guardar();
    await fotos.soltarSustituida(
      anterior: anterior,
      actual: actual,
      deshecho: true,
    );
    expect(await almacen.leer(anterior, TamanoImagen.completa), isNotNull);
    expect(await almacen.leer(actual, TamanoImagen.completa), isNull);
  });
}
