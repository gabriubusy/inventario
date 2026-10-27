import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/salidas/domain/medida_venta.dart';

void main() {
  const saco = Presentacion(nombre: 'Saco', factor: 15000, precio: 3000);
  const kilo = Presentacion(nombre: 'Kilo', factor: 1000, precio: 220);
  const lote = LoteMarca(marca: 'Propia', cantidad: 26500, precio: 200);

  test('one sack takes 15 kg out and costs its price', () {
    const medida = MedidaEnPresentacion(saco);
    expect(medida.aBase(1000), 15000);
    expect(medida.importe(1000, lote), 3000);
  });

  test('2,5 loose kilos take 2,5 kg and cost 2,5 × the kilo price', () {
    const medida = MedidaEnPresentacion(kilo);
    expect(medida.aBase(2500), 2500);
    expect(medida.importe(2500, lote), 550);
  });

  test('says how many packs the stock covers', () {
    expect(const MedidaEnPresentacion(saco).desdeBase(26500), 1766);
    expect(const MedidaEnPresentacion(kilo).desdeBase(26500), 26500);
  });

  test('without packs, the brand price per unit applies', () {
    const medida = MedidaEnUnidad(UnidadBase.kg);
    expect(medida.aBase(2500), 2500);
    expect(medida.importe(2500, lote), 500);
    expect(
      medida.importe(2500, const LoteMarca(marca: 'X', cantidad: 1)),
      isNull,
    );
  });
}
