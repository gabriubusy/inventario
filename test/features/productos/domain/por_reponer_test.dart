import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/por_reponer.dart';
import 'package:inventario/features/productos/domain/producto.dart';

Producto _producto(
  String id,
  int cantidad, {
  List<String> proveedores = const ['A'],
}) => Producto(
  id: id,
  nombre: id,
  categoria: Categoria.carnes,
  forma: FormaConteo.porKilo,
  minimo: 8000,
  lotes: [
    for (final p in proveedores)
      LoteMarca(marca: 'Propia', proveedor: p, cantidad: cantidad),
  ],
);

void main() {
  test('lists sold-out first, then low, leaving the rest out', () {
    final bajo = _producto('bajo', 3800);
    final bien = _producto('bien', 18500);
    final agotado = _producto('agotado', 0);
    expect(porReponer([bajo, bien, agotado]), [agotado, bajo]);
  });

  test('names each supplier once, ignoring case and accents', () {
    final producto = _producto(
      'x',
      100,
      proveedores: ['Frigorífico 1', 'frigorifico 1', 'Avícola 1', ''],
    );
    expect(proveedoresDe(producto), ['Frigorífico 1', 'Avícola 1']);
  });
}
