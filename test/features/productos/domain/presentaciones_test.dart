import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/productos/domain/buscar_por_codigo.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/desglose_stock.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

void main() {
  const saco = Presentacion(
    nombre: 'Saco',
    factor: 15000,
    precio: 3000,
    codigo: '7591234000011',
  );
  const kilo = Presentacion(
    nombre: 'Kilo',
    factor: 1000,
    precio: 220,
    codigo: 'PER-KG',
    predeterminada: true,
  );
  Producto perro(int gramos) => Producto(
    id: 'p1',
    nombre: 'Alimento para perro',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 30000,
    lotes: [LoteMarca(marca: 'Propia', cantidad: gramos)],
    presentaciones: const [saco, kilo],
  );

  group('readable stock', () {
    test('splits into the biggest pack and the rest', () {
      expect(textoStock(perro(26500)), '26,5 kg (1 saco + 11,5 kg)');
      expect(textoStock(perro(45000)), '45 kg (3 sacos)');
    });

    test('shows the total alone when not even one pack fits', () {
      expect(textoStock(perro(11500)), '11,5 kg');
      expect(desglosarStock(perro(0)), isNull);
    });

    test('ignores products without packs', () {
      expect(textoStock(perro(26500).copyWith(presentaciones: [])), '26,5 kg');
    });

    test('pluralises pack names ending in a consonant', () {
      const bulto = Presentacion(nombre: 'Bulto', factor: 24000, precio: 1);
      const pack = Presentacion(nombre: 'Pack', factor: 6, precio: 1);
      expect(textoPaquetes(bulto, 2), '2 bultos');
      expect(textoPaquetes(pack, 2), '2 packes');
      expect(textoPaquetes(bulto, 1), '1 bulto');
    });
  });

  group('codes', () {
    test('finds the product and pack by its exact code', () {
      final productos = [perro(26500)];
      final encontrado = buscarPorCodigo(productos, ' per-kg ');
      expect(encontrado?.presentacion, kilo);
      expect(buscarPorCodigo(productos, '759123'), isNull);
    });

    test('a code used by another product is taken', () {
      final productos = [perro(26500)];
      expect(codigoEnUso(productos, '7591234000011'), isTrue);
      expect(
        codigoEnUso(productos, '7591234000011', exceptoProductoId: 'p1'),
        isFalse,
      );
    });
  });

  test('the marked pack is offered first', () {
    expect(perro(0).presentacionPredeterminada, kilo);
    expect(
      perro(0).copyWith(presentaciones: [saco]).presentacionPredeterminada,
      saco,
    );
  });

  test('with packs, prices come from them, not from the brands', () {
    expect(perro(0).rangoPrecio, (minimo: 220, maximo: 3000));
  });
}
