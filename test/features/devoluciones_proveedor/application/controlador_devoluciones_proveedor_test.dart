import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/data/repositorio_compras_en_memoria.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/devoluciones_proveedor/application/controlador_devoluciones_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/data/repositorio_devoluciones_proveedor_en_memoria.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/compensacion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/motivo_devolucion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/resultado_devolucion_proveedor.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/data/repositorio_incidencias_en_memoria.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  const proveedor = 'Distribuidora 1';
  const jamon = Producto(
    id: 'j',
    nombre: 'Jamón de pierna',
    categoria: Categoria.embutidos,
    forma: FormaConteo.piezasYKilos,
    minimo: 2,
    lotes: [
      LoteMarca(
        marca: 'Plumrose',
        proveedor: proveedor,
        piezas: 4,
        cantidad: 16900,
        costo: 620,
      ),
    ],
  );
  // 2 pieces, 8,4 kg at $ 6,20/kg = $ 52,08.
  const devuelta = LineaCompra(
    productoId: 'j',
    producto: 'Jamón de pierna',
    forma: FormaConteo.piezasYKilos,
    marca: 'Plumrose',
    piezas: 2,
    cantidad: 8400,
    costo: 620,
  );
  final hoy = DateTime(2026, 10, 29, 12);
  int? tasa = 88623;
  late ControladorExistencias existencias;
  late ControladorMovimientos movimientos;
  late ControladorCompras compras;
  late ControladorIncidencias incidencias;
  late ControladorDevolucionesProveedor devoluciones;
  late String compraId;

  setUp(() async {
    tasa = 88623;
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria([jamon]),
    );
    await existencias.cargar();
    movimientos = ControladorMovimientos(RepositorioMovimientosEnMemoria());
    compras = ControladorCompras(
      RepositorioComprasEnMemoria(
        compras: [
          Compra(
            id: 'c1',
            fecha: DateTime(2026, 10, 22),
            proveedor: proveedor,
            factura: '0231',
            lineas: const [
              LineaCompra(
                productoId: 'j',
                producto: 'Jamón de pierna',
                forma: FormaConteo.piezasYKilos,
                marca: 'Plumrose',
                piezas: 4,
                cantidad: 16900,
                costo: 620,
              ),
            ],
            vence: DateTime(2026, 11, 6),
          ),
        ],
      ),
      existencias,
      tasaDeHoy: () => tasa,
      ahora: () => hoy,
    );
    await compras.cargar();
    compraId = compras.cuentas.single.compra.id;
    incidencias = ControladorIncidencias(
      RepositorioIncidenciasEnMemoria(),
      existencias,
      ahora: () => hoy,
    );
    await incidencias.cargar();
    devoluciones = ControladorDevolucionesProveedor(
      RepositorioDevolucionesProveedorEnMemoria(),
      existencias,
      compras,
      movimientos: movimientos,
      incidencias: incidencias,
      ahora: () => hoy,
    );
    await devoluciones.cargar();
  });

  tearDown(() {
    devoluciones.dispose();
    incidencias.dispose();
    compras.dispose();
    movimientos.dispose();
    existencias.dispose();
  });

  LoteMarca lote() => existencias.productos.single.lotes.single;

  Future<ResultadoDevolucionProveedor> devolver(
    Compensacion compensacion, {
    List<LineaCompra> lineas = const [devuelta],
    MedioPago medio = MedioPago.efectivoDolares,
    Incidencia? incidencia,
  }) => devoluciones.registrar(
    proveedor: proveedor,
    motivo: MotivoDevolucion.danado,
    lineas: lineas,
    compensacion: compensacion,
    compraId: compraId,
    medio: medio,
    incidencia: incidencia,
  );

  test('a discount takes the goods out and lowers the invoice', () async {
    final antes = compras.cuentas.single.debe;
    final resultado = await devolver(Compensacion.descuento);
    expect(resultado, isA<DevolucionRegistrada>());
    expect(lote().piezas, 2);
    expect(lote().cantidad, 8500);
    expect(compras.cuentas.single.devuelto, 5208);
    expect(compras.cuentas.single.debe, antes - 5208);
    final anotado = movimientos.todos.single;
    expect(anotado.tipo, TipoMovimiento.devolucionProveedor);
    expect(anotado.nota, 'Vino dañado');
  });

  test('more than the lot holds is refused and nothing changes', () async {
    const demasiado = LineaCompra(
      productoId: 'j',
      producto: 'Jamón de pierna',
      forma: FormaConteo.piezasYKilos,
      marca: 'Plumrose',
      piezas: 3,
      cantidad: 9000,
      costo: 620,
    );
    final resultado = await devolver(
      Compensacion.repone,
      lineas: const [devuelta, demasiado],
    );
    expect(resultado, isA<DevolucionNoAlcanza>());
    expect(lote().piezas, 4);
    expect(devoluciones.todas, isEmpty);
  });

  test('a discount bigger than the debt is refused', () async {
    const caro = LineaCompra(
      productoId: 'j',
      producto: 'Jamón de pierna',
      forma: FormaConteo.piezasYKilos,
      marca: 'Plumrose',
      piezas: 2,
      cantidad: 8400,
      costo: 99900,
    );
    final resultado = await devolver(
      Compensacion.descuento,
      lineas: const [caro],
    );
    expect(resultado, isA<DevolucionExcedeDeuda>());
    expect(lote().piezas, 4);
  });

  test('money back in bolívares is kept at today\'s rate', () async {
    final resultado = await devolver(
      Compensacion.dinero,
      medio: MedioPago.pagoMovil,
    );
    final devolucion = (resultado as DevolucionRegistrada).devolucion;
    expect(devolucion.medio, MedioPago.pagoMovil);
    expect(devolucion.tasa, 88623);
    expect(devolucion.entregado, 4615486);
    expect(compras.cuentas.single.devuelto, 0);
  });

  test('money back in bolívares without a rate is refused', () async {
    tasa = null;
    final resultado = await devolver(
      Compensacion.dinero,
      medio: MedioPago.efectivoBolivares,
    );
    expect(resultado, isA<DevolucionSinTasa>());
  });

  test('from an incident that took the goods out, the stock stays and the '
      'incident is answered', () async {
    final incidencia = Incidencia(
      id: 'i1',
      fecha: hoy,
      proveedor: proveedor,
      productoId: 'j',
      producto: 'Jamón de pierna',
      forma: FormaConteo.piezasYKilos,
      marca: 'Plumrose',
      tipo: TipoIncidencia.malEstado,
      piezas: 2,
      cantidad: 8400,
      sacada: true,
    );
    final repo = RepositorioIncidenciasEnMemoria([incidencia]);
    final conIncidencia = ControladorIncidencias(
      repo,
      existencias,
      ahora: () => hoy,
    );
    await conIncidencia.cargar();
    final desdeIncidencia = ControladorDevolucionesProveedor(
      RepositorioDevolucionesProveedorEnMemoria(),
      existencias,
      compras,
      movimientos: movimientos,
      incidencias: conIncidencia,
      ahora: () => hoy,
    );
    final resultado = await desdeIncidencia.registrar(
      proveedor: proveedor,
      motivo: MotivoDevolucion.danado,
      lineas: const [devuelta],
      compensacion: Compensacion.repone,
      incidencia: incidencia,
    );
    expect((resultado as DevolucionRegistrada).devolucion.sacada, isFalse);
    expect(lote().piezas, 4);
    expect(movimientos.todos, isEmpty);
    expect(conIncidencia.todas.single.respuesta, RespuestaProveedor.devuelto);
    await desdeIncidencia.deshacer();
    expect(conIncidencia.todas.single.abierta, isTrue);
    desdeIncidencia.dispose();
    conIncidencia.dispose();
  });

  test('undo puts the stock, the kardex and the debt back', () async {
    final antes = compras.cuentas.single.debe;
    await devolver(Compensacion.descuento);
    expect(await devoluciones.deshacer(), isTrue);
    expect(lote().piezas, 4);
    expect(lote().cantidad, 16900);
    expect(movimientos.todos, isEmpty);
    expect(compras.cuentas.single.debe, antes);
    expect(devoluciones.todas, isEmpty);
  });

  test('goods to be replaced stay pending until marked as brought', () async {
    await devolver(Compensacion.repone);
    expect(devoluciones.todas.single.pendiente, isTrue);
    await devoluciones.marcarRepuesta(devoluciones.todas.single);
    expect(devoluciones.todas.single.pendiente, isFalse);
    expect(devoluciones.todas.single.repuesta, hoy);
  });

  test('only invoices of that supplier still owed are offered', () async {
    expect(devoluciones.cuentasCon('distribuidora 1'), hasLength(1));
    expect(devoluciones.cuentasCon('Otro'), isEmpty);
    expect(devoluciones.facturaDe(compraId), '0231');
  });
}
