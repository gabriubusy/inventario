import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/app/base_datos/transacciones_drift.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_drift.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/repositorio_movimientos.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_drift.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/domain/salida.dart';

void main() {
  const molida = Producto(
    id: 'p1',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 0,
    lotes: [LoteMarca(marca: 'Propia', cantidad: 10000, precio: 620)],
  );
  const venta = Salida(marca: 'Propia', cantidad: 2000);
  late BaseDatos db;
  late RepositorioProductosDrift productos;
  late ControladorExistencias existencias;

  setUp(() async {
    db = BaseDatos(NativeDatabase.memory());
    productos = RepositorioProductosDrift(db);
    await productos.sembrar([molida]);
    existencias = ControladorExistencias(productos);
    await existencias.cargar();
  });

  tearDown(() async {
    existencias.dispose();
    await db.close();
  });

  ControladorSalidas salidasCon(RepositorioMovimientos repositorio) =>
      ControladorSalidas(
        existencias,
        movimientos: ControladorMovimientos(repositorio),
        transacciones: TransaccionesDrift(db),
      );

  test('a sale saves the stock and its movement together', () async {
    await salidasCon(RepositorioMovimientosDrift(db)).registrar('p1', venta);
    final guardado = (await productos.obtenerTodos()).single;
    expect(guardado.lotes.single.cantidad, 8000);
    expect(await RepositorioMovimientosDrift(db).obtenerTodos(), hasLength(1));
  });

  test('if noting the sale fails, the stock is not taken out', () async {
    final salidas = salidasCon(_MovimientosQueFallan());
    await expectLater(
      salidas.registrar('p1', venta),
      throwsA(isA<_DiscoLleno>()),
    );
    expect((await productos.obtenerTodos()).single, molida);
  });
}

class _DiscoLleno implements Exception {}

class _MovimientosQueFallan implements RepositorioMovimientos {
  @override
  Future<Movimiento> anotar(Movimiento movimiento) => throw _DiscoLleno();

  @override
  Future<void> anular(String id, {DateTime? el}) async {}

  @override
  Future<List<Movimiento>> obtenerTodos() async => const [];

  @override
  Future<void> quitar(String id) async {}

  @override
  Future<void> renombrarProveedor(String anterior, String nuevo) async {}
}
