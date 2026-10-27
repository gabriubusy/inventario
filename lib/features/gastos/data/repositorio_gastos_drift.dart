import 'package:drift/drift.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/app/base_datos/nuevo_id.dart';
import 'package:inventario/features/gastos/domain/gasto.dart';
import 'package:inventario/features/gastos/domain/repositorio_gastos.dart';

class RepositorioGastosDrift implements RepositorioGastos {
  RepositorioGastosDrift(this._db);

  final BaseDatos _db;

  @override
  Future<List<Gasto>> obtenerTodos() async => [
    for (final f in await _db.select(_db.gastos).get())
      Gasto(
        id: f.id,
        fecha: f.fecha,
        categoria: f.categoria,
        medio: f.medio,
        monto: f.monto,
        tasa: f.tasa,
        nota: f.nota,
      ),
  ];

  @override
  Future<Gasto> crear(Gasto gasto) async {
    final guardado = gasto.conId(nuevoId('g'));
    await _db
        .into(_db.gastos)
        .insert(
          GastosCompanion.insert(
            id: guardado.id,
            fecha: guardado.fecha,
            categoria: guardado.categoria,
            medio: guardado.medio,
            monto: guardado.monto,
            tasa: Value(guardado.tasa),
            nota: guardado.nota,
          ),
        );
    return guardado;
  }

  @override
  Future<void> quitar(String id) =>
      (_db.delete(_db.gastos)..where((t) => t.id.equals(id))).go();
}
