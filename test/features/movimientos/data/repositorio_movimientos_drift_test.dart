import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_drift.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

void main() {
  final venta = Movimiento(
    fecha: DateTime(2026, 10, 27, 9, 41, 12, 345, 678),
    tipo: TipoMovimiento.venta,
    productoId: 'p1',
    producto: 'Carne molida',
    forma: FormaConteo.porKilo,
    marca: 'Propia',
    proveedor: 'Frigorífico 1',
    cantidad: 2000,
    importe: 1240,
    costo: 900,
    abrioPieza: true,
    tasa: 88730,
    nota: 'Cliente fijo',
  );
  late BaseDatos db;
  late RepositorioMovimientosDrift repositorio;

  setUp(() {
    db = BaseDatos(NativeDatabase.memory());
    repositorio = RepositorioMovimientosDrift(db);
  });

  tearDown(() => db.close());

  test('a sale comes back exactly, with its local time and rate', () async {
    final anotada = await repositorio.anotar(venta);
    expect(anotada.id, isNotEmpty);
    expect(await repositorio.obtenerTodos(), [anotada]);
  });

  test('cancelling keeps the sale, marked as cancelled', () async {
    final anotada = await repositorio.anotar(venta);
    await repositorio.anular(anotada.id);
    expect((await repositorio.obtenerTodos()).single, anotada.anulado());
  });

  test('undoing removes it', () async {
    final anotada = await repositorio.anotar(venta);
    await repositorio.quitar(anotada.id);
    expect(await repositorio.obtenerTodos(), isEmpty);
  });

  test('comes back in date order', () async {
    final tarde = await repositorio.anotar(
      venta.conFecha(DateTime(2026, 10, 27, 18)),
    );
    final temprano = await repositorio.anotar(
      venta.conFecha(DateTime(2026, 10, 27, 8)),
    );
    expect(await repositorio.obtenerTodos(), [temprano, tarde]);
  });
}
