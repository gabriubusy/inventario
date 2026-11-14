import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/compras/data/repositorio_compras_drift.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/estado_pedido.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/compras/domain/pago.dart';
import 'package:inventario/features/compras/domain/recepcion.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

void main() {
  final compra = Compra(
    fecha: DateTime(2026, 10, 27, 9, 30),
    proveedor: 'Distribuidora 1',
    factura: '0231',
    lineas: const [
      LineaCompra(
        productoId: 'j',
        producto: 'Jamón de pierna',
        forma: FormaConteo.piezasYKilos,
        marca: 'Marca F',
        piezas: 4,
        cantidad: 16800,
        costo: 690,
      ),
      LineaCompra(
        productoId: 's',
        producto: 'Suero',
        forma: FormaConteo.porLitro,
        marca: 'Marca C',
        cantidad: 48000,
        costo: 408,
      ),
    ],
    vence: DateTime(2026, 11, 11),
    tasa: 88623,
  );
  late BaseDatos db;
  late RepositorioComprasDrift repositorio;

  setUp(() {
    db = BaseDatos(NativeDatabase.memory());
    repositorio = RepositorioComprasDrift(db);
  });

  tearDown(() => db.close());

  test('an invoice comes back with its lines in order', () async {
    final guardada = await repositorio.crearCompra(compra);
    expect(guardada.id, isNotEmpty);
    expect(await repositorio.obtenerCompras(), [guardada]);
  });

  test('payments are kept, and deleting the invoice takes them', () async {
    final guardada = await repositorio.crearCompra(compra);
    final pago = await repositorio.crearPago(
      Pago(
        compraId: guardada.id,
        fecha: DateTime(2026, 10, 28),
        medio: MedioPago.pagoMovil,
        monto: 5000,
        entregado: 4431150,
        tasa: 88623,
        referencia: '0412',
      ),
    );
    expect(await repositorio.obtenerPagos(), [pago]);
    await repositorio.borrarCompra(guardada.id);
    expect(await repositorio.obtenerCompras(), isEmpty);
    expect(await repositorio.obtenerPagos(), isEmpty);
  });

  test('what arrived of each line is kept, line by line', () async {
    final guardada = await repositorio.crearCompra(compra);
    expect(guardada.lineas.every((l) => !l.recibida), isTrue);
    final recibida = guardada.conRecepcion(
      conLlegadas(guardada, [(indice: 1, piezas: 0, cantidad: 47000)]),
      cuando: DateTime(2026, 10, 28, 8),
    );
    await repositorio.guardarRecepcion(recibida);
    final leida = (await repositorio.obtenerCompras()).single;
    expect(leida, recibida);
    expect(leida.estado, EstadoPedido.parcial);
    expect(leida.lineas.first.recibida, isFalse);
    expect(leida.lineas.last.cantidadRecibida, 47000);
    expect(leida.recibidaEl, DateTime(2026, 10, 28, 8));
  });

  test('renaming a supplier carries its invoices', () async {
    await repositorio.crearCompra(compra);
    await repositorio.renombrarProveedor(
      'distribuidora 1',
      'Distribuidora Uno',
    );
    expect(
      (await repositorio.obtenerCompras()).single.proveedor,
      'Distribuidora Uno',
    );
  });
}
