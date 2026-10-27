import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/incidencias/data/repositorio_incidencias_en_memoria.dart';
import 'package:inventario/features/incidencias/domain/datos_incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

void main() {
  final datos = DatosIncidencia(
    fecha: DateTime(2026, 10, 26),
    proveedor: 'Distribuidora 1',
    productoId: 'p1',
    producto: 'Queso blanco duro',
    forma: FormaConteo.piezasYKilos,
    marca: 'Marca A',
    tipo: TipoIncidencia.vencido,
    piezas: 1,
    cantidad: 800,
    sacada: true,
  );

  test('creates with a new id and keeps every typed field', () async {
    final repositorio = RepositorioIncidenciasEnMemoria();
    final creada = await repositorio.crear(datos);
    expect(creada.id, isNotEmpty);
    expect(creada.tipo, TipoIncidencia.vencido);
    expect(creada.sacada, isTrue);
    expect(creada.abierta, isTrue);
    expect(await repositorio.obtenerTodas(), [creada]);
  });

  test('saves an answer and deletes on undo', () async {
    final repositorio = RepositorioIncidenciasEnMemoria();
    final creada = await repositorio.crear(datos);
    final respondida = creada.conRespuesta(RespuestaProveedor.repuso);
    await repositorio.actualizar(respondida);
    expect(await repositorio.obtenerTodas(), [respondida]);
    await repositorio.borrar(creada.id);
    expect(await repositorio.obtenerTodas(), isEmpty);
  });

  test('renaming a supplier carries its incidents along', () async {
    final repositorio = RepositorioIncidenciasEnMemoria();
    await repositorio.crear(datos);
    await repositorio.renombrarProveedor(
      'distribuidora 1',
      'Distribuidora Uno',
    );
    final todas = await repositorio.obtenerTodas();
    expect(todas.single.proveedor, 'Distribuidora Uno');
  });
}
