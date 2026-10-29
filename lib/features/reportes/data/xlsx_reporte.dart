import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:inventario/features/reportes/domain/reporte.dart';

/// The report as a real Excel workbook (.xlsx): its title, then the table
/// with a bold header. Right-aligned columns go as numbers so Excel can add
/// them up; a cell that doesn't read as one stays text.
Uint8List xlsxDeReporte(Reporte reporte) {
  final archivos = {
    '[Content_Types].xml': _tipos,
    '_rels/.rels': _relaciones,
    'xl/workbook.xml': _libro(reporte.titulo),
    'xl/_rels/workbook.xml.rels': _relacionesLibro,
    'xl/styles.xml': _estilos,
    'xl/worksheets/sheet1.xml': _hoja(reporte),
  };
  final zip = Archive();
  for (final MapEntry(key: ruta, value: xml) in archivos.entries) {
    zip.addFile(ArchiveFile.bytes(ruta, utf8.encode(xml)));
  }
  return Uint8List.fromList(ZipEncoder().encode(zip));
}

/// "$ 1.234,50", "−3,1 kg" or "45 %" as 1234.5, -3.1 or 45; null when the
/// text is not a figure (a dash, a name).
double? numeroDeCelda(String texto) {
  // "2 kg (1 saco + 3 kg)" holds several figures: it stays text.
  if (RegExp(r'\d[\d.,]*').allMatches(texto).length != 1) return null;
  final limpio = texto
      .replaceAll('−', '-')
      .replaceAll(RegExp(r'[^0-9,.\-]'), '')
      .replaceAll('.', '')
      .replaceAll(',', '.');
  if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(limpio)) return null;
  return double.parse(limpio);
}

String _hoja(Reporte reporte) {
  final filas = StringBuffer()
    ..write('<row r="1">${_texto('A1', reporte.titulo, negrita: true)}</row>');
  final cabecera = reporte.columnas.indexed
      .map((c) => _texto('${_columna(c.$1)}3', c.$2, negrita: true))
      .join();
  filas.write('<row r="3">$cabecera</row>');
  for (final (i, fila) in reporte.filas.indexed) {
    final numero = i + 4;
    final celdas = fila.indexed.map((c) {
      final ref = '${_columna(c.$1)}$numero';
      final valor = reporte.numericas.contains(c.$1)
          ? numeroDeCelda(c.$2)
          : null;
      return valor == null
          ? _texto(ref, c.$2)
          : '<c r="$ref"><v>$valor</v></c>';
    }).join();
    filas.write('<row r="$numero">$celdas</row>');
  }
  return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '<sheetData>$filas</sheetData></worksheet>';
}

String _texto(String ref, String texto, {bool negrita = false}) =>
    '<c r="$ref" t="inlineStr"${negrita ? ' s="1"' : ''}>'
    '<is><t xml:space="preserve">${_escapar(texto)}</t></is></c>';

/// 0 → A, 25 → Z, 26 → AA.
String _columna(int indice) {
  var resto = indice + 1;
  final letras = StringBuffer();
  while (resto > 0) {
    final letra = (resto - 1) % 26;
    letras.write(String.fromCharCode(65 + letra));
    resto = (resto - 1) ~/ 26;
  }
  return letras.toString().split('').reversed.join();
}

String _escapar(String texto) => texto
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

/// Excel caps sheet names at 31 characters and forbids a few symbols.
String _libro(String titulo) {
  final nombre = titulo.replaceAll(RegExp(r'[\\/?*\[\]:]'), ' ');
  final corto = nombre.length > 31 ? nombre.substring(0, 31) : nombre;
  return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
      '<sheets><sheet name="${_escapar(corto)}" sheetId="1" r:id="rId1"/></sheets>'
      '</workbook>';
}

const _tipos =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
    '<Default Extension="xml" ContentType="application/xml"/>'
    '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
    '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
    '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
    '</Types>';

const _relaciones =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
    '</Relationships>';

const _relacionesLibro =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
    '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
    '</Relationships>';

/// Style 0 is plain, style 1 bold (title and header).
const _estilos =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
    '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font>'
    '<font><b/><sz val="11"/><name val="Calibri"/></font></fonts>'
    '<fills count="2"><fill><patternFill patternType="none"/></fill>'
    '<fill><patternFill patternType="gray125"/></fill></fills>'
    '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
    '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
    '<cellXfs count="2"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
    '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/></cellXfs>'
    '</styleSheet>';
