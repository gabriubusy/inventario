import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/incidencias/domain/filtrar_incidencias.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/resumen_incidencias.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

Incidencia _incidencia(
  String id,
  DateTime fecha, {
  String proveedor = 'Distribuidora 1',
  String producto = 'Queso blanco duro',
  String marca = 'Marca A',
  RespuestaProveedor? respuesta,
}) => Incidencia(
  id: id,
  fecha: fecha,
  proveedor: proveedor,
  productoId: 'p1',
  producto: producto,
  forma: FormaConteo.piezasYKilos,
  marca: marca,
  tipo: TipoIncidencia.malEstado,
  cantidad: 1000,
  respuesta: respuesta,
);

void main() {
  final hoy = DateTime(2026, 10, 26, 12);

  test('is open until the supplier answers, and can be reopened', () {
    final incidencia = _incidencia('1', hoy);
    expect(incidencia.abierta, isTrue);
    final respondida = incidencia.conRespuesta(RespuestaProveedor.repuso);
    expect(respondida.abierta, isFalse);
    expect(respondida.conRespuesta(null), incidencia);
  });

  test('is overdue when open for more than a week', () {
    expect(_incidencia('1', DateTime(2026, 10, 19)).atrasada(hoy), isFalse);
    expect(_incidencia('1', DateTime(2026, 10, 18)).atrasada(hoy), isTrue);
    expect(
      _incidencia(
        '1',
        DateTime(2026, 9, 1),
        respuesta: RespuestaProveedor.descuento,
      ).atrasada(hoy),
      isFalse,
    );
  });

  test('filters by supplier, product or brand, and by open', () {
    final todas = [
      _incidencia('1', hoy),
      _incidencia(
        '2',
        hoy,
        proveedor: 'Frigorífico 1',
        producto: 'Carne molida',
        marca: 'Propia',
        respuesta: RespuestaProveedor.repuso,
      ),
    ];
    expect(filtrarIncidencias(todas, texto: 'frigorifico'), [todas[1]]);
    expect(filtrarIncidencias(todas, texto: 'molida'), [todas[1]]);
    expect(filtrarIncidencias(todas, texto: 'marca a'), [todas[0]]);
    expect(filtrarIncidencias(todas, soloAbiertas: true), [todas[0]]);
    expect(incidenciasDe('FRIGORIFICO 1', todas), [todas[1]]);
  });

  test('summary counts open ones and the supplier with most this month', () {
    final todas = [
      _incidencia('1', hoy),
      _incidencia('2', DateTime(2026, 10, 3)),
      _incidencia(
        '3',
        DateTime(2026, 10, 5),
        proveedor: 'Frigorífico 1',
        respuesta: RespuestaProveedor.repuso,
      ),
      // Last month: not in "este mes" but still open.
      _incidencia('4', DateTime(2026, 9, 20), proveedor: 'Frigorífico 1'),
    ];
    expect(
      ResumenIncidencias.de(todas, hoy),
      const ResumenIncidencias(
        abiertas: 3,
        delMes: 3,
        proveedorConMas: 'Distribuidora 1',
        deEseProveedor: 2,
      ),
    );
    expect(
      ResumenIncidencias.de(const [], hoy),
      const ResumenIncidencias(abiertas: 0, delMes: 0),
    );
  });
}
