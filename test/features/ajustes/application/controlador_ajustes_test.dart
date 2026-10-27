import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/ajustes/application/controlador_ajustes.dart';
import 'package:inventario/features/ajustes/domain/ajuste.dart';
import 'package:inventario/features/ajustes/domain/resultado_ajuste.dart';
import 'package:inventario/features/ajustes/domain/tipo_ajuste.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  const molida = Producto(
    id: 'p1',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 8000,
    lotes: [
      LoteMarca(marca: 'Propia', proveedor: 'Frigorífico 1', cantidad: 3800),
    ],
  );
  const recorte = Ajuste(
    tipo: TipoAjuste.merma,
    motivo: 'Recorte',
    marca: 'Propia',
    proveedor: 'Frigorífico 1',
    cantidad: 400,
    nota: 'Al limpiar',
  );
  late ControladorExistencias existencias;
  late ControladorMovimientos movimientos;
  late ControladorAjustes ajustes;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria([molida]),
    );
    await existencias.cargar();
    movimientos = ControladorMovimientos(RepositorioMovimientosEnMemoria());
    ajustes = ControladorAjustes(existencias, movimientos: movimientos);
  });

  tearDown(() {
    ajustes.dispose();
    movimientos.dispose();
    existencias.dispose();
  });

  int cantidad() => existencias.productos.single.cantidad;

  test('a merma takes the goods out and is noted with its reason', () async {
    final resultado = await ajustes.registrar('p1', recorte);
    expect(resultado, isA<AjusteRegistrado>());
    expect(cantidad(), 3400);
    final anotado = movimientos.todos.single;
    expect(anotado.tipo, TipoMovimiento.merma);
    expect(anotado.nota, 'Recorte · Al limpiar');
  });

  test('a theft is noted as such', () async {
    await ajustes.registrar(
      'p1',
      const Ajuste(
        tipo: TipoAjuste.robo,
        motivo: 'Robo',
        marca: 'Propia',
        proveedor: 'Frigorífico 1',
        cantidad: 1000,
      ),
    );
    expect(movimientos.todos.single.tipo, TipoMovimiento.robo);
  });

  test('more than the lot holds is refused and saves nothing', () async {
    final resultado = await ajustes.registrar(
      'p1',
      const Ajuste(
        tipo: TipoAjuste.merma,
        motivo: 'Vencido',
        marca: 'Propia',
        proveedor: 'Frigorífico 1',
        cantidad: 3801,
      ),
    );
    expect(resultado, isA<AjusteSinExistencias>());
    expect(cantidad(), 3800);
    expect(movimientos.todos, isEmpty);
  });

  test('undo puts the goods back and removes the movement', () async {
    await ajustes.registrar('p1', recorte);
    expect(await ajustes.deshacer(), isTrue);
    expect(cantidad(), 3800);
    expect(movimientos.todos, isEmpty);
  });

  test('undo is refused when the product changed afterwards', () async {
    await ajustes.registrar('p1', recorte);
    final cambiado = existencias.productos.single.copyWith(minimo: 1);
    await existencias.actualizarProducto('p1', DatosProducto.desde(cambiado));
    expect(await ajustes.deshacer(), isFalse);
    expect(cantidad(), 3400);
  });
}
