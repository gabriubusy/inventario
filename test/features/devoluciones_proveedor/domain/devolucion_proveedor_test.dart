import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/compensacion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/devolucion_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/lineas_de_incidencia.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/motivo_devolucion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/resumen_devoluciones_proveedor.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  final hoy = DateTime(2026, 10, 29, 12);
  const mortadela = LineaCompra(
    productoId: 'm',
    producto: 'Mortadela',
    forma: FormaConteo.porKilo,
    marca: 'Plumrose',
    cantidad: 4000,
    costo: 310,
  );

  DevolucionProveedor devolucion(
    Compensacion compensacion, {
    String? compraId,
    DateTime? fecha,
  }) => DevolucionProveedor(
    fecha: fecha ?? hoy,
    proveedor: 'Distribuidora 1',
    motivo: MotivoDevolucion.vencido,
    lineas: const [mortadela, mortadela],
    compensacion: compensacion,
    compraId: compraId,
  );

  test('the total is every line at its cost', () {
    expect(devolucion(Compensacion.dinero).total, 2480);
  });

  test('only discounts count against their invoice', () {
    expect(
      devueltoPorCompra([
        devolucion(Compensacion.descuento, compraId: 'c1'),
        devolucion(Compensacion.descuento, compraId: 'c1'),
        devolucion(Compensacion.dinero, compraId: 'c2'),
      ]),
      {'c1': 4960},
    );
  });

  test('goods to be replaced are pending until brought', () {
    final repone = devolucion(Compensacion.repone);
    expect(repone.pendiente, isTrue);
    expect(repone.conRepuesta(hoy).pendiente, isFalse);
    expect(repone.conRepuesta(hoy).conRepuesta(null).pendiente, isTrue);
    expect(devolucion(Compensacion.dinero).pendiente, isFalse);
  });

  test('the summary counts this month and every pending one', () {
    final resumen = ResumenDevolucionesProveedor.de([
      devolucion(Compensacion.descuento, compraId: 'c1'),
      devolucion(Compensacion.dinero),
      devolucion(Compensacion.repone, fecha: DateTime(2026, 9, 3)),
    ], hoy);
    expect(
      resumen,
      const ResumenDevolucionesProveedor(
        devuelto: 4960,
        cuantas: 2,
        descontado: 2480,
        pendientes: 1,
      ),
    );
  });

  test('an incident becomes a line at its lot cost', () {
    const producto = Producto(
      id: 'm',
      nombre: 'Mortadela',
      categoria: Categoria.embutidos,
      forma: FormaConteo.porKilo,
      minimo: 0,
      lotes: [
        LoteMarca(
          marca: 'Plumrose',
          proveedor: 'Distribuidora 1',
          cantidad: 9000,
          costo: 310,
        ),
      ],
    );
    final incidencia = Incidencia(
      id: 'i1',
      fecha: hoy,
      proveedor: 'Distribuidora 1',
      productoId: 'm',
      producto: 'Mortadela',
      forma: FormaConteo.porKilo,
      marca: 'plumrose',
      tipo: TipoIncidencia.vencido,
      cantidad: 4000,
    );
    expect(lineasDeIncidencia(incidencia, const [producto]).single.costo, 310);
    expect(motivoDeIncidencia(incidencia), MotivoDevolucion.vencido);
    expect(motivoDeIncidencia(null), MotivoDevolucion.danado);
  });
}
