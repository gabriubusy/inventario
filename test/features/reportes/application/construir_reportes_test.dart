import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/gastos/domain/categoria_gasto.dart';
import 'package:inventario/features/gastos/domain/gasto.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/reportes/application/construir_reportes.dart';
import 'package:inventario/features/reportes/domain/reporte.dart';

void main() {
  final hoy = DateTime(2026, 10, 27, 12);
  Movimiento venta(
    String producto,
    int importe,
    int costo, {
    String ventaId = 'v1',
    int diasAtras = 0,
    bool anulada = false,
  }) => Movimiento(
    id: '$producto$ventaId',
    fecha: hoy.subtract(Duration(days: diasAtras)),
    tipo: TipoMovimiento.venta,
    productoId: producto,
    producto: producto,
    forma: FormaConteo.porKilo,
    marca: 'A',
    cantidad: 1000,
    importe: importe,
    costo: costo,
    ventaId: ventaId,
    anulada: anulada,
  );
  final gasto = Gasto(
    fecha: hoy,
    categoria: CategoriaGasto.servicios,
    medio: MedioPago.efectivoDolares,
    monto: 300,
  );
  DatosReportes datos({
    List<Movimiento> movimientos = const [],
    List<Producto> productos = const [],
    List<Gasto> gastos = const [],
  }) => (
    movimientos: movimientos,
    productos: productos,
    cuentas: const [],
    pagos: const [],
    gastos: gastos,
  );

  test('sales count tickets once and leave cancelled lines out', () {
    final reporte = construirReporte(
      TipoReporte.ventas,
      PeriodoReporte.hoy,
      datos(
        movimientos: [
          venta('Queso', 1000, 700),
          venta('Jamón', 500, 300),
          venta('Queso', 900, 600, ventaId: 'v2', anulada: true),
          venta('Queso', 400, 300, ventaId: 'v3', diasAtras: 3),
        ],
      ),
      hoy,
    );
    expect(reporte.cifras.first.valor, r'$ 15,00');
    expect(reporte.filas.single[1], '1');
    expect(reporte.filas.single[2], '2');
  });

  test('a customer return comes off the sales and the profit', () {
    final devolucion = Movimiento(
      id: 'd1',
      fecha: hoy,
      tipo: TipoMovimiento.devolucionCliente,
      productoId: 'Queso',
      producto: 'Queso',
      forma: FormaConteo.porKilo,
      marca: 'A',
      cantidad: 1000,
      importe: 1000,
      costo: 700,
      origenId: 'Quesov1',
    );
    final movimientos = [venta('Queso', 1000, 700), devolucion];
    final ventas = construirReporte(
      TipoReporte.ventas,
      PeriodoReporte.hoy,
      datos(movimientos: movimientos),
      hoy,
    );
    expect(ventas.cifras.first.valor, r'$ 0,00');
    expect(ventas.filas.single[1], '1');
    final ganancia = construirReporte(
      TipoReporte.ganancia,
      PeriodoReporte.hoy,
      datos(movimientos: movimientos),
      hoy,
    );
    expect(ganancia.cifras.last.valor, r'$ 0,00');
  });

  test('an older return without its cost takes its share of the sale', () {
    final vieja = Movimiento(
      id: 'd2',
      fecha: hoy,
      tipo: TipoMovimiento.devolucionCliente,
      productoId: 'Queso',
      producto: 'Queso',
      forma: FormaConteo.porKilo,
      marca: 'A',
      cantidad: 500,
      importe: 500,
      origenId: 'Quesov1',
    );
    final ganancia = construirReporte(
      TipoReporte.ganancia,
      PeriodoReporte.hoy,
      datos(movimientos: [venta('Queso', 1000, 700), vieja]),
      hoy,
    );
    // Sold $10 − $5 back; cost $7 − $3,50 back: $1,50.
    expect(ganancia.cifras.last.valor, r'$ 1,50');
  });

  test('profit is sales minus their cost minus expenses', () {
    final reporte = construirReporte(
      TipoReporte.ganancia,
      PeriodoReporte.mes,
      datos(
        movimientos: [venta('Queso', 1000, 700), venta('Jamón', 500, 300)],
        gastos: [gasto],
      ),
      hoy,
    );
    expect(reporte.cifras.last.valor, r'$ 2,00');
    expect(reporte.filas.first, [
      'Queso',
      r'$ 10,00',
      r'$ 7,00',
      '30 %',
      r'$ 3,00',
    ]);
  });

  test('stock is valued at its cost and at its price', () {
    const producto = Producto(
      id: 'q',
      nombre: 'Queso',
      categoria: Categoria.quesos,
      forma: FormaConteo.porKilo,
      minimo: 0,
      lotes: [LoteMarca(marca: 'A', cantidad: 2500, costo: 400, precio: 520)],
    );
    final reporte = construirReporte(
      TipoReporte.inventario,
      PeriodoReporte.todo,
      datos(productos: const [producto]),
      hoy,
    );
    expect(reporte.filas.single.sublist(2), [r'$ 10,00', r'$ 13,00']);
  });

  test('expenses group by category', () {
    final reporte = construirReporte(
      TipoReporte.gastos,
      PeriodoReporte.semana,
      datos(gastos: [gasto, gasto]),
      hoy,
    );
    expect(reporte.filas.single, ['Servicios', 'Gasto', '2', r'$ 6,00']);
  });
}
