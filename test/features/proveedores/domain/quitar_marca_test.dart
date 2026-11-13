import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/proveedores/domain/quitar_marca.dart';

void main() {
  Producto producto(String id, List<LoteMarca> lotes) => Producto(
    id: id,
    nombre: 'Queso $id',
    categoria: Categoria.quesos,
    forma: FormaConteo.porKilo,
    minimo: 0,
    lotes: lotes,
  );

  const vacio = LoteMarca(
    marca: 'Marca A',
    proveedor: 'Distribuidora 1',
    cantidad: 0,
  );
  const conStock = LoteMarca(
    marca: 'Marca A',
    proveedor: 'Distribuidora 1',
    cantidad: 500,
  );
  const deOtro = LoteMarca(
    marca: 'Marca A',
    proveedor: 'Distribuidora 2',
    cantidad: 800,
  );

  test('a brand nobody has stock of can be taken off', () {
    expect(
      marcaSinExistencias(
        [
          producto('a', [vacio]),
          producto('b', [vacio]),
        ],
        proveedor: 'distribuidora 1',
        marca: 'marca a',
      ),
      isTrue,
    );
  });

  test('stock in one product keeps the brand', () {
    expect(
      marcaSinExistencias(
        [
          producto('a', [vacio]),
          producto('b', [conStock]),
        ],
        proveedor: 'Distribuidora 1',
        marca: 'Marca A',
      ),
      isFalse,
    );
  });

  test('the same brand from another supplier does not count', () {
    expect(
      marcaSinExistencias(
        [
          producto('a', [deOtro]),
        ],
        proveedor: 'Distribuidora 1',
        marca: 'Marca A',
      ),
      isTrue,
    );
  });

  test('only the products with that lot change', () {
    final cambios = productosSinMarca(
      [
        producto('a', [vacio, deOtro]),
        producto('b', [deOtro]),
      ],
      proveedor: 'Distribuidora 1',
      marca: 'Marca A',
    );
    expect(cambios, hasLength(1));
    expect(cambios.single.antes.id, 'a');
    expect(cambios.single.despues.lotes, [deOtro]);
  });

  test('a brand nobody carries changes nothing', () {
    expect(
      productosSinMarca(
        [
          producto('a', [vacio]),
        ],
        proveedor: 'Distribuidora 1',
        marca: 'Marca Z',
      ),
      isEmpty,
    );
  });
}
