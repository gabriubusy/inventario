import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/features/incidencias/data/repositorio_incidencias_drift.dart';
import 'package:inventario/features/incidencias/domain/datos_incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

void main() {
  final vencido = DatosIncidencia(
    fecha: DateTime(2026, 10, 20, 10, 30),
    proveedor: 'Lácteos Sur',
    productoId: 'p1',
    producto: 'Queso blanco duro',
    forma: FormaConteo.piezasYKilos,
    marca: 'Marca A',
    tipo: TipoIncidencia.vencido,
    piezas: 1,
    cantidad: 820,
    nota: 'Olía raro',
    sacada: true,
  );
  late BaseDatos db;
  late RepositorioIncidenciasDrift repositorio;

  setUp(() {
    db = BaseDatos(NativeDatabase.memory());
    repositorio = RepositorioIncidenciasDrift(db);
  });

  tearDown(() => db.close());

  test('an incident is saved open and keeps the answer given', () async {
    final creada = await repositorio.crear(vencido);
    expect(await repositorio.obtenerTodas(), [creada]);
    final respondida = creada.conRespuesta(RespuestaProveedor.values.first);
    await repositorio.actualizar(respondida);
    expect(await repositorio.obtenerTodas(), [respondida]);
  });

  test('renaming a supplier renames its incidents', () async {
    await repositorio.crear(vencido);
    await repositorio.renombrarProveedor('lacteos sur', 'Lácteos del Sur');
    expect(
      (await repositorio.obtenerTodas()).single.proveedor,
      'Lácteos del Sur',
    );
  });

  test('undoing a registration deletes it', () async {
    final creada = await repositorio.crear(vencido);
    await repositorio.borrar(creada.id);
    expect(await repositorio.obtenerTodas(), isEmpty);
  });
}
