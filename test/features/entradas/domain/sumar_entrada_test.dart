import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/entradas/domain/entrada.dart';
import 'package:inventario/features/entradas/domain/sumar_entrada.dart';
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
        precio: 980,
      ),
      LoteMarca(
        marca: 'Marca B',
        proveedor: 'Distribuidora 2',
        piezas: 14,
        piezaAbierta: true,
        cantidad: 11000,
      ),
    ],
  );

  test('adds pieces and weight to the matching brand lot', () {
    const entrada = Entrada(
      marca: 'Marca A',
      proveedor: 'Distribuidora 1',
      piezas: 6,
      cantidad: 4900,
    );
    final despues = sumarEntrada(queso, entrada);
    expect(despues.lotes.first.piezas, 16);
    expect(despues.lotes.first.cantidad, 13100);
    expect(despues.lotes.last, queso.lotes.last);
  });

  test('keeps the lot price and open piece untouched', () {
    const entrada = Entrada(
      marca: 'Marca B',
      proveedor: 'Distribuidora 2',
      piezas: 1,
      cantidad: 800,
    );
    final lote = sumarEntrada(queso, entrada).lotes.last;
    expect(lote.piezaAbierta, isTrue);
    expect(
      sumarEntrada(
        queso,
        const Entrada(
          marca: 'marca a',
          proveedor: 'DISTRIBUIDORA 1',
          piezas: 1,
          cantidad: 800,
        ),
      ).lotes.first.precio,
      980,
    );
  });

  test('matches the lot ignoring case and accents', () {
    const entrada = Entrada(
      marca: 'marca a',
      proveedor: 'distribuidora 1',
      piezas: 1,
      cantidad: 800,
    );
    expect(indiceLoteDeEntrada(queso, entrada), 0);
    expect(sumarEntrada(queso, entrada).lotes, hasLength(2));
  });

  test('a new brand or supplier becomes a new lot at the end', () {
    const entrada = Entrada(
      marca: 'Marca A',
      proveedor: 'Lácteos 1',
      piezas: 3,
      cantidad: 2500,
    );
    expect(indiceLoteDeEntrada(queso, entrada), -1);
    final despues = sumarEntrada(queso, entrada);
    expect(despues.lotes, hasLength(3));
    expect(
      despues.lotes.last,
      const LoteMarca(
        marca: 'Marca A',
        proveedor: 'Lácteos 1',
        piezas: 3,
        cantidad: 2500,
      ),
    );
  });
}
