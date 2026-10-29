import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/reportes/data/xlsx_reporte.dart';
import 'package:inventario/features/reportes/domain/reporte.dart';

void main() {
  const reporte = Reporte(
    titulo: 'Más vendidos',
    cifras: [],
    columnas: ['Producto', 'Vendido', 'Importe'],
    filas: [
      ['Carne molida', '12,5 kg', r'$ 1.234,50'],
      ['Queso & jamón', '2 kg (1 saco + 3 kg)', '—'],
    ],
    numericas: {1, 2},
  );

  String hoja(Reporte r) {
    final zip = ZipDecoder().decodeBytes(xlsxDeReporte(r));
    return utf8.decode(zip.findFile('xl/worksheets/sheet1.xml')!.content);
  }

  test('reads Venezuelan figures as numbers', () {
    expect(numeroDeCelda(r'$ 1.234,50'), 1234.5);
    expect(numeroDeCelda('−3,1 kg'), -3.1);
    expect(numeroDeCelda('45 %'), 45);
    expect(numeroDeCelda('—'), isNull);
    expect(numeroDeCelda('2 kg (1 saco + 3 kg)'), isNull);
  });

  test('is a workbook with the title and a bold header', () {
    final zip = ZipDecoder().decodeBytes(xlsxDeReporte(reporte));
    expect(zip.findFile('[Content_Types].xml'), isNotNull);
    expect(zip.findFile('xl/workbook.xml'), isNotNull);
    final xml = hoja(reporte);
    expect(xml, contains('<t xml:space="preserve">Más vendidos</t>'));
    expect(xml, contains('<c r="A3" t="inlineStr" s="1">'));
  });

  test('figure columns go as numbers, the rest as escaped text', () {
    final xml = hoja(reporte);
    expect(xml, contains('<c r="B4"><v>12.5</v></c>'));
    expect(xml, contains('<c r="C4"><v>1234.5</v></c>'));
    expect(xml, contains('Queso &amp; jamón'));
    expect(xml, contains('2 kg (1 saco + 3 kg)'));
  });
}
