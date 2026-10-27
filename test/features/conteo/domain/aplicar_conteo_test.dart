import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/conteo/domain/aplicar_conteo.dart';
import 'package:inventario/features/conteo/domain/conteo_lote.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  const lote = LoteMarca(
    marca: 'Marca H',
    proveedor: 'Distribuidora 2',
    piezas: 2,
    piezaAbierta: true,
    cantidad: 6100,
  );
  const mortadela = Producto(
    id: 'p1',
    nombre: 'Mortadela',
    categoria: Categoria.embutidos,
    forma: FormaConteo.piezasYKilos,
    minimo: 1,
    lotes: [lote],
  );

  test('the difference is counted minus recorded', () {
    const conteo = ConteoLote(
      productoId: 'p1',
      marca: 'Marca H',
      proveedor: 'Distribuidora 2',
      piezas: 1,
      cantidad: 5000,
    );
    expect(diferenciaConteo(lote, conteo), (piezas: -1, cantidad: -1100));
  });

  test('pieces left out of the count keep the recorded ones', () {
    const conteo = ConteoLote(
      productoId: 'p1',
      marca: 'Marca H',
      proveedor: 'Distribuidora 2',
      cantidad: 6100,
    );
    expect(hayDiferencia(diferenciaConteo(lote, conteo)), isFalse);
  });

  test('applying sets the lot to what was counted', () {
    const conteo = ConteoLote(
      productoId: 'p1',
      marca: 'marca h',
      proveedor: 'distribuidora 2',
      piezas: 1,
      cantidad: 5000,
    );
    final despues = aplicarConteo(mortadela, conteo)!.lotes.single;
    expect(despues.piezas, 1);
    expect(despues.cantidad, 5000);
    expect(despues.piezaAbierta, isTrue);
  });

  test('nothing left closes the open piece', () {
    const conteo = ConteoLote(
      productoId: 'p1',
      marca: 'Marca H',
      proveedor: 'Distribuidora 2',
      piezas: 0,
      cantidad: 0,
    );
    expect(
      aplicarConteo(mortadela, conteo)!.lotes.single.piezaAbierta,
      isFalse,
    );
  });

  test('an unknown lot is not applied', () {
    const conteo = ConteoLote(productoId: 'p1', marca: 'Otra', cantidad: 1);
    expect(aplicarConteo(mortadela, conteo), isNull);
  });
}
