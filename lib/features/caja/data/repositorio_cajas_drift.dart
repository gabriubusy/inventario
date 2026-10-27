import 'package:drift/drift.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/app/base_datos/nuevo_id.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/caja/domain/caja.dart';
import 'package:inventario/features/caja/domain/repositorio_cajas.dart';

class RepositorioCajasDrift implements RepositorioCajas {
  RepositorioCajasDrift(this._db);

  final BaseDatos _db;

  @override
  Future<List<Caja>> obtenerTodas() async => [
    for (final f in await _db.select(_db.cajas).get())
      Caja(
        id: f.id,
        abierta: f.abierta,
        fondoDolares: f.fondoDolares,
        fondoBolivares: f.fondoBolivares,
        cerrada: f.cerrada,
        contado: _leerContado(f.contado),
        nota: f.nota,
      ),
  ];

  @override
  Future<Caja> abrir(Caja caja) async {
    final guardada = caja.conId(nuevoId('k'));
    await _db.into(_db.cajas).insert(_fila(guardada));
    return guardada;
  }

  @override
  Future<void> cerrar(Caja caja) => (_db.update(
    _db.cajas,
  )..where((t) => t.id.equals(caja.id))).write(_fila(caja));

  CajasCompanion _fila(Caja c) => CajasCompanion.insert(
    id: c.id,
    abierta: c.abierta,
    fondoDolares: c.fondoDolares,
    fondoBolivares: c.fondoBolivares,
    cerrada: Value(c.cerrada),
    contado: [
      for (final MapEntry(key: medio, value: monto) in c.contado.entries)
        '${medio.name}=$monto',
    ].join(';'),
    nota: c.nota,
  );

  static Map<MedioPago, int> _leerContado(String texto) => {
    for (final par in texto.split(';'))
      if (par.split('=') case [final nombre, final monto])
        ?MedioPago.values.asNameMap()[nombre]: int.parse(monto),
  };
}
