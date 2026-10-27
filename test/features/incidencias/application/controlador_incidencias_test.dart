import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/data/repositorio_incidencias_en_memoria.dart';
import 'package:inventario/features/incidencias/domain/datos_incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/resultado_incidencia.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  const queso = Producto(
    id: 'p1',
    nombre: 'Queso blanco duro',
    categoria: Categoria.quesos,
    forma: FormaConteo.piezasYKilos,
    minimo: 5,
    lotes: [
      LoteMarca(
        marca: 'Marca A',
        proveedor: 'Distribuidora 1',
        piezas: 10,
        cantidad: 8200,
      ),
    ],
  );
  final hoy = DateTime(2026, 10, 26, 10);
  late ControladorExistencias existencias;
  late ControladorIncidencias incidencias;

  DatosIncidencia datos({bool sacada = true, int piezas = 2}) =>
      DatosIncidencia(
        fecha: hoy,
        proveedor: 'Distribuidora 1',
        productoId: 'p1',
        producto: 'Queso blanco duro',
        forma: FormaConteo.piezasYKilos,
        marca: 'Marca A',
        tipo: TipoIncidencia.malEstado,
        piezas: piezas,
        cantidad: 1600,
        sacada: sacada,
      );

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria([queso]),
    );
    await existencias.cargar();
    incidencias = ControladorIncidencias(
      RepositorioIncidenciasEnMemoria(),
      existencias,
      ahora: () => hoy,
    );
    await incidencias.cargar();
  });

  tearDown(() {
    incidencias.dispose();
    existencias.dispose();
  });

  LoteMarca loteActual() => existencias.productos.single.lotes.single;

  test('registering with "sacar" takes the goods out of the stock', () async {
    final resultado = await incidencias.registrar(datos());
    expect(resultado, isA<IncidenciaRegistrada>());
    expect(loteActual().piezas, 8);
    expect(loteActual().cantidad, 6600);
    expect(incidencias.abiertasDe('distribuidora 1'), 1);
  });

  test('registering without "sacar" leaves the stock alone', () async {
    await incidencias.registrar(datos(sacada: false));
    expect(loteActual(), queso.lotes.single);
    expect(incidencias.todas, hasLength(1));
  });

  test('refuses and saves nothing when the lot no longer holds it', () async {
    final resultado = await incidencias.registrar(datos(piezas: 11));
    expect(resultado, isA<ExistenciaInsuficiente>());
    expect(incidencias.todas, isEmpty);
    expect(loteActual(), queso.lotes.single);
  });

  test('undo removes the incident and puts the goods back', () async {
    await incidencias.registrar(datos());
    expect(await incidencias.deshacer(), isTrue);
    expect(incidencias.todas, isEmpty);
    expect(loteActual(), queso.lotes.single);
    expect(incidencias.puedeDeshacer, isFalse);
  });

  test('undo is refused when the product changed afterwards', () async {
    await incidencias.registrar(datos());
    final cambiado = existencias.productos.single.copyWith(minimo: 3);
    await existencias.actualizarProducto('p1', DatosProducto.desde(cambiado));
    expect(await incidencias.deshacer(), isFalse);
    expect(incidencias.todas, hasLength(1));
    expect(loteActual().piezas, 8);
  });

  test('an answer closes the incident and null reopens it', () async {
    await incidencias.registrar(datos(sacada: false));
    final incidencia = incidencias.todas.single;
    await incidencias.responder(incidencia, RespuestaProveedor.repuso);
    expect(incidencias.todas.single.respuesta, RespuestaProveedor.repuso);
    expect(incidencias.abiertasDe('Distribuidora 1'), 0);
    await incidencias.responder(incidencias.todas.single, null);
    expect(incidencias.todas.single.abierta, isTrue);
  });

  test('lists the newest first', () async {
    await incidencias.registrar(datos(sacada: false));
    await incidencias.registrar(
      DatosIncidencia(
        fecha: DateTime(2026, 10, 27),
        proveedor: 'Distribuidora 1',
        productoId: 'p1',
        producto: 'Queso blanco duro',
        forma: FormaConteo.piezasYKilos,
        marca: 'Marca A',
        tipo: TipoIncidencia.vencido,
        cantidad: 500,
        sacada: false,
      ),
    );
    expect(incidencias.todas.first.tipo, TipoIncidencia.vencido);
  });
}
