import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/features/productos/data/repositorio_productos_drift.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/regla_precio.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';

void main() {
  const alimento = DatosProducto(
    nombre: 'Alimento para perro',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 10000,
    lotes: [
      LoteMarca(
        marca: 'Dogui',
        proveedor: 'Distribuidora Norte',
        cantidad: 45000,
        precio: 250,
        costo: 180,
      ),
      LoteMarca(marca: 'Pedigree', cantidad: 15000),
    ],
    presentaciones: [
      Presentacion(
        nombre: 'Saco',
        factor: 15000,
        precio: 3200,
        codigo: '7591234000011',
      ),
      Presentacion(
        nombre: 'Kilo',
        factor: 1000,
        precio: 250,
        predeterminada: true,
      ),
    ],
  );
  late BaseDatos db;
  late RepositorioProductosDrift repositorio;

  setUp(() {
    db = BaseDatos(NativeDatabase.memory());
    repositorio = RepositorioProductosDrift(db);
  });

  tearDown(() => db.close());

  Future<Producto> crear(DatosProducto datos) async =>
      switch (await repositorio.crear(datos)) {
        ProductoGuardado(:final producto) => producto,
        NombreRepetido() => throw StateError('name taken'),
      };

  test('the Mayor and Especial rules are kept and replaced', () async {
    final creado = await crear(
      DatosProducto(
        nombre: alimento.nombre,
        categoria: alimento.categoria,
        forma: alimento.forma,
        minimo: alimento.minimo,
        lotes: alimento.lotes,
        reglas: const {
          ListaPrecio.mayor: MargenSobreCosto(3000),
          ListaPrecio.especial: PrecioFijo(500),
        },
      ),
    );
    expect((await repositorio.obtenerTodos()).single, creado);
    await repositorio.actualizar(
      creado.id,
      DatosProducto.desde(
        creado.copyWith(reglas: const {ListaPrecio.mayor: PrecioFijo(450)}),
      ),
    );
    expect((await repositorio.obtenerTodos()).single.reglas, const {
      ListaPrecio.mayor: PrecioFijo(450),
    });
  });

  test('a product comes back with its brands and packs in order', () async {
    final creado = await crear(alimento);
    expect(await repositorio.obtenerTodos(), [creado]);
    expect(creado.lotes.first.costo, 180);
    expect(creado.presentaciones.last.predeterminada, isTrue);
  });

  test('refuses a name already used, ignoring case and accents', () async {
    await crear(alimento);
    final otro = await repositorio.crear(
      const DatosProducto(
        nombre: 'ALIMENTO PARA PERRÓ',
        categoria: Categoria.carnes,
        forma: FormaConteo.porKilo,
        minimo: 0,
      ),
    );
    expect(otro, isA<NombreRepetido>());
  });

  test('editing replaces the brands and packs', () async {
    final creado = await crear(alimento);
    const editado = DatosProducto(
      nombre: 'Alimento para perro',
      categoria: Categoria.carnes,
      forma: FormaConteo.porKilo,
      minimo: 5000,
      lotes: [LoteMarca(marca: 'Dogui', cantidad: 44000, precio: 260)],
    );
    await repositorio.actualizar(creado.id, editado);
    final guardado = (await repositorio.obtenerTodos()).single;
    expect(guardado.minimo, 5000);
    expect(guardado.lotes, editado.lotes);
    expect(guardado.presentaciones, isEmpty);
  });

  test('deleting takes its brands and packs with it', () async {
    final creado = await crear(alimento);
    await repositorio.borrar(creado.id);
    expect(await repositorio.obtenerTodos(), isEmpty);
    expect(await db.select(db.lotesMarca).get(), isEmpty);
    expect(await db.select(db.presentaciones).get(), isEmpty);
  });

  test('renaming a supplier renames its lots only', () async {
    await crear(alimento);
    await repositorio.renombrarProveedor(
      'distribuidora norte',
      'Distribuidora del Norte',
    );
    final lotes = (await repositorio.obtenerTodos()).single.lotes;
    expect(lotes.map((l) => l.proveedor), ['Distribuidora del Norte', '']);
  });

  test('the data is still there after closing the app', () async {
    final carpeta = await Directory.systemTemp.createTemp('inventario');
    addTearDown(() => carpeta.delete(recursive: true));
    final archivo = File('${carpeta.path}/inventario.sqlite');

    final primera = BaseDatos(NativeDatabase(archivo));
    final creado = await RepositorioProductosDrift(primera).crear(alimento);
    await primera.close();

    final segunda = BaseDatos(NativeDatabase(archivo));
    addTearDown(segunda.close);
    expect(await RepositorioProductosDrift(segunda).obtenerTodos(), [
      (creado as ProductoGuardado).producto,
    ]);
  });
}
