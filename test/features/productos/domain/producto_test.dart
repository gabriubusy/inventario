import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  const jamon = Producto(
    id: '1',
    nombre: 'Jamón',
    categoria: Categoria.embutidos,
    unidad: UnidadBase.kg,
    existencia: 5000,
    minimo: 5000,
  );

  test('is available at or above the minimum', () {
    expect(jamon.estado, EstadoStock.disponible);
  });

  test('is low below the minimum', () {
    expect(jamon.copyWith(existencia: 4999).estado, EstadoStock.bajo);
  });

  test('is out of stock at zero or less', () {
    expect(jamon.copyWith(existencia: 0).estado, EstadoStock.agotado);
    expect(jamon.copyWith(existencia: -10).estado, EstadoStock.agotado);
  });

  test('products with the same data are equal', () {
    expect(jamon, jamon.copyWith());
    expect(jamon.hashCode, jamon.copyWith().hashCode);
    expect(jamon, isNot(jamon.copyWith(existencia: 1)));
  });
}
