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
