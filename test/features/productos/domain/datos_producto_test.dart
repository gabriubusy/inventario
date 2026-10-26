import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  test('starts without stock unless brands are given', () {
    const datos = DatosProducto(
      nombre: 'Mortadela',
      categoria: Categoria.embutidos,
      forma: FormaConteo.piezasYKilos,
      minimo: 1,
    );
    expect(datos.lotes, isEmpty);
  });

  test('data with the same values are equal, brands included', () {
    DatosProducto datos() => const DatosProducto(
      nombre: 'Mortadela',
      categoria: Categoria.embutidos,
      forma: FormaConteo.piezasYKilos,
      minimo: 1,
      lotes: [LoteMarca(marca: 'H', piezas: 2, cantidad: 6100)],
    );
    expect(datos(), datos());
    expect(datos().hashCode, datos().hashCode);
  });

  test('copies a saved product, photo included, to undo an edit', () {
    const producto = Producto(
      id: 'p1',
      nombre: 'Mortadela',
      categoria: Categoria.embutidos,
      forma: FormaConteo.piezasYKilos,
      minimo: 1,
      lotes: [LoteMarca(marca: 'H', piezas: 2, cantidad: 6100, precio: 450)],
      imagenId: 'foto',
    );
    expect(
      DatosProducto.desde(producto),
      const DatosProducto(
        nombre: 'Mortadela',
        categoria: Categoria.embutidos,
        forma: FormaConteo.piezasYKilos,
        minimo: 1,
        lotes: [LoteMarca(marca: 'H', piezas: 2, cantidad: 6100, precio: 450)],
        imagenId: 'foto',
      ),
    );
  });
}
