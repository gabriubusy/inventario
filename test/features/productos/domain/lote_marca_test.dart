import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';

void main() {
  const lote = LoteMarca(
    marca: 'Marca A',
    proveedor: 'Distribuidora 1',
    piezas: 10,
    cantidad: 8200,
  );

  test('starts closed and without supplier unless told', () {
    const minimo = LoteMarca(marca: 'X', cantidad: 1);
    expect(minimo.proveedor, '');
    expect(minimo.piezas, 0);
    expect(minimo.piezaAbierta, isFalse);
  });

  test('copyWith changes only the given fields', () {
    final abierto = lote.copyWith(piezaAbierta: true);
    expect(abierto.piezaAbierta, isTrue);
    expect(abierto.copyWith(piezaAbierta: false), lote);
  });

  test('lots with the same data are equal', () {
    expect(lote, lote.copyWith());
    expect(lote.hashCode, lote.copyWith().hashCode);
    expect(lote, isNot(lote.copyWith(proveedor: 'Otro')));
  });
}
