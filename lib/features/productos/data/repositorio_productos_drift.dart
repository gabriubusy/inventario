import 'package:drift/drift.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/app/base_datos/nuevo_id.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/regla_precio.dart';
import 'package:inventario/features/productos/domain/repositorio_productos.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';

/// Products in SQLite: one row each, plus their brand lots and packs, all
/// written together in one transaction.
class RepositorioProductosDrift implements RepositorioProductos {
  RepositorioProductosDrift(this._db);

  final BaseDatos _db;

  @override
  Future<List<Producto>> obtenerTodos() async {
    final filas = await (_db.select(
      _db.productos,
    )..orderBy([(t) => OrderingTerm(expression: t.rowId)])).get();
    final lotes = await (_db.select(
      _db.lotesMarca,
    )..orderBy([(t) => OrderingTerm(expression: t.orden)])).get();
    final presentaciones = await (_db.select(
      _db.presentaciones,
    )..orderBy([(t) => OrderingTerm(expression: t.orden)])).get();
    final reglas = await _db.select(_db.reglasPrecio).get();
    return [
      for (final fila in filas)
        _aProducto(
          fila,
          lotes.where((l) => l.productoId == fila.id),
          presentaciones.where((p) => p.productoId == fila.id),
          reglas.where((r) => r.productoId == fila.id),
        ),
    ];
  }

  @override
  Future<ResultadoGuardarProducto> crear(DatosProducto datos) =>
      _db.transaction(() async {
        if (await _nombreUsado(datos.nombre)) return const NombreRepetido();
        final id = nuevoId('p');
        await _escribir(id, datos, nuevo: true);
        return ProductoGuardado(_construir(id, datos));
      });

  @override
  Future<ResultadoGuardarProducto> actualizar(String id, DatosProducto datos) =>
      _db.transaction(() async {
        if (await _nombreUsado(datos.nombre, excepto: id)) {
          return const NombreRepetido();
        }
        await _escribir(id, datos, nuevo: false);
        return ProductoGuardado(_construir(id, datos));
      });

  @override
  Future<void> borrar(String id) =>
      (_db.delete(_db.productos)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    final clave = normalizarParaBusqueda(anterior);
    await _db.transaction(() async {
      for (final lote in await _db.select(_db.lotesMarca).get()) {
        if (normalizarParaBusqueda(lote.proveedor) != clave) continue;
        await (_db.update(_db.lotesMarca)..where(
              (t) =>
                  t.productoId.equals(lote.productoId) &
                  t.orden.equals(lote.orden),
            ))
            .write(LotesMarcaCompanion(proveedor: Value(nuevo)));
      }
    });
  }

  /// Example products with their own ids, for a first run while developing.
  Future<void> sembrar(List<Producto> productos) => _db.transaction(() async {
    for (final producto in productos) {
      await _escribir(producto.id, DatosProducto.desde(producto), nuevo: true);
    }
  });

  Future<bool> _nombreUsado(String nombre, {String? excepto}) async {
    final consulta = _db.select(_db.productos)
      ..where((t) => t.nombreClave.equals(normalizarParaBusqueda(nombre)));
    if (excepto != null) consulta.where((t) => t.id.equals(excepto).not());
    return (await consulta.get()).isNotEmpty;
  }

  /// Lots and packs are rewritten whole: simpler than diffing, and few.
  Future<void> _escribir(
    String id,
    DatosProducto datos, {
    required bool nuevo,
  }) async {
    final fila = ProductosCompanion.insert(
      id: id,
      nombre: datos.nombre,
      nombreClave: normalizarParaBusqueda(datos.nombre),
      categoria: datos.categoria,
      forma: datos.forma,
      minimo: datos.minimo,
      imagenId: Value(datos.imagenId),
    );
    if (nuevo) {
      await _db.into(_db.productos).insert(fila);
    } else {
      await (_db.update(
        _db.productos,
      )..where((t) => t.id.equals(id))).write(fila);
      await (_db.delete(
        _db.lotesMarca,
      )..where((t) => t.productoId.equals(id))).go();
      await (_db.delete(
        _db.presentaciones,
      )..where((t) => t.productoId.equals(id))).go();
      await (_db.delete(
        _db.reglasPrecio,
      )..where((t) => t.productoId.equals(id))).go();
    }
    await _db.batch((lote) {
      lote.insertAll(_db.lotesMarca, [
        for (final (orden, l) in datos.lotes.indexed)
          LotesMarcaCompanion.insert(
            productoId: id,
            orden: orden,
            marca: l.marca,
            proveedor: l.proveedor,
            piezas: l.piezas,
            piezaAbierta: l.piezaAbierta,
            cantidad: l.cantidad,
            precio: Value(l.precio),
            costo: Value(l.costo),
          ),
      ]);
      lote.insertAll(_db.presentaciones, [
        for (final (orden, p) in datos.presentaciones.indexed)
          PresentacionesCompanion.insert(
            productoId: id,
            orden: orden,
            nombre: p.nombre,
            factor: p.factor,
            precio: p.precio,
            codigo: p.codigo,
            predeterminada: p.predeterminada,
          ),
      ]);
      lote.insertAll(_db.reglasPrecio, [
        for (final MapEntry(key: lista, value: regla) in datos.reglas.entries)
          ReglasPrecioCompanion.insert(
            productoId: id,
            lista: lista,
            tipo: switch (regla) {
              MargenSobreCosto() => _margen,
              PrecioFijo() => _fijo,
            },
            valor: switch (regla) {
              MargenSobreCosto(:final porcentaje) => porcentaje,
              PrecioFijo(:final precio) => precio,
            },
          ),
      ]);
    });
  }

  static const _margen = 'margen';
  static const _fijo = 'fijo';

  Producto _construir(String id, DatosProducto datos) => Producto(
    id: id,
    nombre: datos.nombre,
    categoria: datos.categoria,
    forma: datos.forma,
    minimo: datos.minimo,
    lotes: List.unmodifiable(datos.lotes),
    presentaciones: List.unmodifiable(datos.presentaciones),
    imagenId: datos.imagenId,
    reglas: Map.unmodifiable(datos.reglas),
  );

  Producto _aProducto(
    FilaProducto fila,
    Iterable<FilaLoteMarca> lotes,
    Iterable<FilaPresentacion> presentaciones,
    Iterable<FilaReglaPrecio> reglas,
  ) => Producto(
    id: fila.id,
    nombre: fila.nombre,
    categoria: fila.categoria,
    forma: fila.forma,
    minimo: fila.minimo,
    imagenId: fila.imagenId,
    reglas: Map.unmodifiable({
      for (final r in reglas)
        r.lista: r.tipo == _fijo
            ? PrecioFijo(r.valor)
            : MargenSobreCosto(r.valor),
    }),
    lotes: List.unmodifiable([
      for (final l in lotes)
        LoteMarca(
          marca: l.marca,
          proveedor: l.proveedor,
          piezas: l.piezas,
          piezaAbierta: l.piezaAbierta,
          cantidad: l.cantidad,
          precio: l.precio,
          costo: l.costo,
        ),
    ]),
    presentaciones: List.unmodifiable([
      for (final p in presentaciones)
        Presentacion(
          nombre: p.nombre,
          factor: p.factor,
          precio: p.precio,
          codigo: p.codigo,
          predeterminada: p.predeterminada,
        ),
    ]),
  );
}
