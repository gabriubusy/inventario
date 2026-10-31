import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

void main() {
  Movimiento venta(String id, String proveedor) => Movimiento(
    id: id,
    fecha: DateTime(2026, 10, 29),
    tipo: TipoMovimiento.venta,
    productoId: 'p',
    producto: 'Queso',
    forma: FormaConteo.porKilo,
    marca: 'A',
    proveedor: proveedor,
    cantidad: 1000,
  );

  test('renaming a supplier renames it in past sales too', () async {
    final movimientos = ControladorMovimientos(
      RepositorioMovimientosEnMemoria([
        venta('m1', 'Lácteos ABC'),
        venta('m2', 'Otro'),
      ]),
    );
    addTearDown(movimientos.dispose);
    await movimientos.cargar();
    await movimientos.renombrarProveedor('lacteos abc', 'Lácteos ABC C.A.');
    final porId = {for (final m in movimientos.todos) m.id: m.proveedor};
    expect(porId, {'m1': 'Lácteos ABC C.A.', 'm2': 'Otro'});
  });
}
