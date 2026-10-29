import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/devoluciones_proveedor/data/repositorio_devoluciones_proveedor_drift.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/compensacion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/devolucion_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/motivo_devolucion.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

void main() {
  late BaseDatos db;
  late RepositorioDevolucionesProveedorDrift repositorio;
  final devolucion = DevolucionProveedor(
    fecha: DateTime(2026, 10, 29, 9, 30),
    proveedor: 'Distribuidora 1',
    motivo: MotivoDevolucion.danado,
    lineas: const [
      LineaCompra(
        productoId: 'j',
        producto: 'Jamón de pierna',
        forma: FormaConteo.piezasYKilos,
        marca: 'Plumrose',
        piezas: 2,
        cantidad: 8400,
        costo: 620,
      ),
      LineaCompra(
        productoId: 'm',
        producto: 'Mortadela',
        forma: FormaConteo.porKilo,
        marca: 'Plumrose',
        cantidad: 4000,
        costo: 310,
      ),
    ],
    compensacion: Compensacion.dinero,
    medio: MedioPago.pagoMovil,
    entregado: 5714570,
    tasa: 88623,
    nota: 'Olía mal',
    incidenciaId: 'i1',
    sacada: false,
  );

  setUp(() {
    db = BaseDatos(NativeDatabase.memory());
    repositorio = RepositorioDevolucionesProveedorDrift(db);
  });

  tearDown(() => db.close());

  test('a return is kept with its lines in order', () async {
    final guardada = await repositorio.crear(devolucion);
    expect(await repositorio.obtenerTodas(), [guardada]);
  });

  test('marking it as brought again is kept', () async {
    final guardada = await repositorio.crear(devolucion);
    final repuesta = guardada.conRepuesta(DateTime(2026, 10, 30));
    await repositorio.actualizar(repuesta);
    expect(await repositorio.obtenerTodas(), [repuesta]);
  });

  test('undo removes it with its lines', () async {
    final guardada = await repositorio.crear(devolucion);
    await repositorio.borrar(guardada.id);
    expect(await repositorio.obtenerTodas(), isEmpty);
    expect(await db.select(db.lineasDevolucion).get(), isEmpty);
  });

  test('renaming a supplier carries its returns', () async {
    await repositorio.crear(devolucion);
    await repositorio.renombrarProveedor('distribuidora 1', 'Distribuidora');
    expect(
      (await repositorio.obtenerTodas()).single.proveedor,
      'Distribuidora',
    );
  });
}
