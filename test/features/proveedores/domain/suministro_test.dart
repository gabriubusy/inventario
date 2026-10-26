import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/domain/suministro.dart';

void main() {
  const distribuidora = Proveedor(id: 'v1', nombre: 'Distribuidora 1');
  const productos = [
    Producto(
      id: '1',
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
          piezas: 14,
          cantidad: 11000,
        ),
      ],
    ),
    Producto(
      id: '2',
      nombre: 'Queso de mano',
      categoria: Categoria.quesos,
      forma: FormaConteo.porKilo,
      minimo: 1000,
      lotes: [
        LoteMarca(
          marca: 'marca a',
          proveedor: 'DISTRIBUIDORA 1',
          cantidad: 3000,
        ),
      ],
    ),
  ];

  test('finds the lots of a supplier ignoring case and accents', () {
    final suministros = suministrosDe(distribuidora, productos);
    expect(suministros.map((s) => s.producto.nombre), [
      'Queso blanco duro',
      'Queso de mano',
    ]);
    expect(suministros.map((s) => s.lote.piezas), [10, 0]);
  });

  test('a supplier without lots brings nothing', () {
    const otro = Proveedor(id: 'v9', nombre: 'Avícola 1');
    expect(suministrosDe(otro, productos), isEmpty);
  });

  test('lists each brand once, in order of appearance', () {
    final suministros = suministrosDe(distribuidora, productos);
    expect(marcasDe(suministros), ['Marca A']);
  });

  test('matches by supplier name or by a brand it brings', () {
    final suministros = suministrosDe(distribuidora, productos);
    expect(coincideProveedor(distribuidora, suministros, ''), isTrue);
    expect(coincideProveedor(distribuidora, suministros, 'distrib'), isTrue);
    expect(coincideProveedor(distribuidora, suministros, 'marca a'), isTrue);
    expect(coincideProveedor(distribuidora, suministros, 'marca b'), isFalse);
  });
}
