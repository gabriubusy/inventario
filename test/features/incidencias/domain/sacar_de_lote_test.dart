import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/incidencias/domain/sacar_de_lote.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  const queso = Producto(
    id: 'p1',
    nombre: 'Queso blanco duro',
    categoria: Categoria.quesos,
    forma: FormaConteo.piezasYKilos,
    minimo: 5,
    lotes: [
      LoteMarca(
        marca: 'Marca A',
        proveedor: 'Distribuidora 1',
        piezas: 10,
        cantidad: 8200,
      ),
      LoteMarca(
        marca: 'Marca B',
        proveedor: 'Distribuidora 2',
        piezas: 1,
        piezaAbierta: true,
        cantidad: 1500,
      ),
    ],
  );

  test('takes the pieces and weight out of the matching lot only', () {
    final despues = sacarDeLote(
      queso,
      marca: 'marca a',
      proveedor: 'DISTRIBUIDORA 1',
      piezas: 2,
      cantidad: 1600,
    );
    expect(despues?.lotes.first.piezas, 8);
    expect(despues?.lotes.first.cantidad, 6600);
    expect(despues?.lotes.last, queso.lotes.last);
  });

  test('refuses to take more than the lot holds', () {
    expect(
      sacarDeLote(
        queso,
        marca: 'Marca A',
        proveedor: 'Distribuidora 1',
        piezas: 11,
        cantidad: 100,
      ),
      isNull,
    );
    expect(
      sacarDeLote(
        queso,
        marca: 'Marca A',
        proveedor: 'Distribuidora 1',
        piezas: 0,
        cantidad: 8201,
      ),
      isNull,
    );
  });

  test('refuses a brand that supplier does not bring', () {
    expect(
      sacarDeLote(
        queso,
        marca: 'Marca A',
        proveedor: 'Distribuidora 2',
        piezas: 0,
        cantidad: 100,
      ),
      isNull,
    );
  });

  test('an open piece stops being open when all its weight goes', () {
    final despues = sacarDeLote(
      queso,
      marca: 'Marca B',
      proveedor: 'Distribuidora 2',
      piezas: 1,
      cantidad: 1500,
    );
    expect(despues?.lotes.last.piezaAbierta, isFalse);
    expect(despues?.lotes.last.tieneExistencia, isFalse);
  });
}
