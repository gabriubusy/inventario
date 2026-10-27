import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/application/controlador_devoluciones.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/domain/devolucion_cliente.dart';
import 'package:inventario/features/salidas/domain/resultado_anulacion.dart';
import 'package:inventario/features/salidas/domain/resultado_devolucion.dart';

void main() {
  const molida = Producto(
    id: 'p1',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 8000,
    lotes: [
      LoteMarca(
        marca: 'Propia',
        proveedor: 'Frigorífico 1',
        cantidad: 1800,
        precio: 620,
      ),
    ],
  );
  late ControladorExistencias existencias;
  late ControladorMovimientos movimientos;
  late ControladorDevoluciones devoluciones;
  late Movimiento venta;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria([molida]),
    );
    await existencias.cargar();
    movimientos = ControladorMovimientos(RepositorioMovimientosEnMemoria());
    devoluciones = ControladorDevoluciones(existencias, movimientos);
    venta = await movimientos.anotar(
      Movimiento(
        fecha: DateTime.now(),
        tipo: TipoMovimiento.venta,
        productoId: 'p1',
        producto: 'Carne molida',
        forma: FormaConteo.porKilo,
        marca: 'Propia',
        proveedor: 'Frigorífico 1',
        cantidad: 2000,
        importe: 1240,
      ),
    );
  });

  tearDown(() {
    devoluciones.dispose();
    movimientos.dispose();
    existencias.dispose();
  });

  int cantidad() => existencias.productos.single.cantidad;

  test('goods in good shape go back to their lot and refund', () async {
    final resultado = await devoluciones.devolver(
      venta,
      cantidad: 1000,
      destino: DestinoDevolucion.stock,
    );
    expect(resultado, isA<DevolucionRegistrada>());
    expect((resultado as DevolucionRegistrada).importe, 620);
    expect(cantidad(), 2800);
    expect(movimientos.resumenDeHoy.vendido, 620);
    expect(devoluciones.devolvibleDe(venta), 1000);
  });

  test('damaged goods are noted as returned and then lost', () async {
    await devoluciones.devolver(
      venta,
      cantidad: 500,
      destino: DestinoDevolucion.merma,
    );
    expect(cantidad(), 1800);
    final tipos = [for (final m in movimientos.todos) m.tipo];
    expect(tipos, contains(TipoMovimiento.devolucionCliente));
    expect(tipos, contains(TipoMovimiento.merma));
  });

  test('more than what is left of the sale is refused', () async {
    await devoluciones.devolver(
      venta,
      cantidad: 1500,
      destino: DestinoDevolucion.stock,
    );
    final resultado = await devoluciones.devolver(
      venta,
      cantidad: 600,
      destino: DestinoDevolucion.stock,
    );
    expect(resultado, isA<DevolucionExcede>());
    expect(cantidad(), 3300);
  });

  test('undo takes the return back', () async {
    await devoluciones.devolver(
      venta,
      cantidad: 1000,
      destino: DestinoDevolucion.stock,
    );
    expect(await devoluciones.deshacer(), isTrue);
    expect(cantidad(), 1800);
    expect(movimientos.todos.single, venta);
  });

  test('a sale with a return can no longer be cancelled whole', () async {
    final salidas = ControladorSalidas(existencias, movimientos: movimientos);
    addTearDown(salidas.dispose);
    await devoluciones.devolver(
      venta,
      cantidad: 1000,
      destino: DestinoDevolucion.stock,
    );
    expect(await salidas.anular(venta), isA<AnulacionConDevolucion>());
    expect(cantidad(), 2800);
  });
}
