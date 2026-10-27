import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

/// Development-only sales and entries earlier today, so the home screen
/// shows its day panel before anything is registered.
List<Movimiento> movimientosDeEjemplo(DateTime ahora) {
  DateTime antes(int minutos) => ahora.subtract(Duration(minutes: minutos));
  return [
    Movimiento(
      id: 'e1',
      fecha: antes(150),
      tipo: TipoMovimiento.entrada,
      productoId: '1',
      producto: 'Bistec de res',
      forma: FormaConteo.porKilo,
      marca: 'Propia',
      cantidad: 10000,
    ),
    Movimiento(
      id: 'e2',
      fecha: antes(95),
      tipo: TipoMovimiento.venta,
      productoId: '1',
      producto: 'Bistec de res',
      forma: FormaConteo.porKilo,
      marca: 'Propia',
      cantidad: 1000,
      importe: 750,
    ),
    Movimiento(
      id: 'e3',
      fecha: antes(60),
      tipo: TipoMovimiento.venta,
      productoId: '7',
      producto: 'Salchicha de pollo',
      forma: FormaConteo.porUnidad,
      marca: 'Marca D',
      cantidad: 3,
      importe: 720,
    ),
    Movimiento(
      id: 'e4',
      fecha: antes(35),
      tipo: TipoMovimiento.venta,
      productoId: '5',
      producto: 'Jamón de pierna',
      forma: FormaConteo.piezasYKilos,
      marca: 'Marca F',
      piezas: 1,
      cantidad: 4200,
      importe: 3780,
    ),
    Movimiento(
      id: 'e5',
      fecha: antes(20),
      tipo: TipoMovimiento.venta,
      productoId: '2',
      producto: 'Carne molida',
      forma: FormaConteo.porKilo,
      marca: 'Propia',
      cantidad: 2000,
      importe: 1240,
    ),
    Movimiento(
      id: 'e6',
      fecha: antes(5),
      tipo: TipoMovimiento.venta,
      productoId: '8',
      producto: 'Queso blanco duro',
      forma: FormaConteo.piezasYKilos,
      marca: 'Marca A',
      cantidad: 1250,
      importe: 650,
    ),
  ];
}
