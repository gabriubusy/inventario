import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:inventario/features/reportes/data/logo_pdf.dart';
import 'package:inventario/features/reportes/data/xlsx_reporte.dart';
import 'package:inventario/features/reportes/domain/exportador_reportes.dart';
import 'package:inventario/features/reportes/domain/reporte.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// PDF through the print dialog and Excel through a save dialog (a
/// download in the browser).
class ExportadorArchivos implements ExportadorReportes {
  const ExportadorArchivos({this.encabezado});

  static const _ladoLogo = 24.0;

  /// The shop's details on top of each PDF; read when printing, so a change
  /// in Configuración shows at once.
  final String Function()? encabezado;

  @override
  Future<void> pdf(Reporte reporte, {required String subtitulo}) =>
      Printing.layoutPdf(
        name: reporte.titulo,
        onLayout: (formato) => _documento(reporte, subtitulo, formato),
      );

  @override
  Future<bool> excel(Reporte reporte, {required String nombre}) async {
    final archivo = XFile.fromData(
      xlsxDeReporte(reporte),
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      name: '$nombre.xlsx',
    );
    if (kIsWeb) {
      await archivo.saveTo('$nombre.xlsx');
      return true;
    }
    final destino = await getSaveLocation(
      suggestedName: '$nombre.xlsx',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Excel', extensions: ['xlsx']),
      ],
    );
    if (destino == null) return false;
    await archivo.saveTo(destino.path);
    return true;
  }

  Future<Uint8List> _documento(
    Reporte reporte,
    String subtitulo,
    PdfPageFormat formato,
  ) async {
    final doc = pw.Document(title: reporte.titulo);
    final negocio = encabezado?.call() ?? '';
    doc.addPage(
      pw.MultiPage(
        pageFormat: formato,
        build: (_) => [
          if (negocio.isNotEmpty)
            pw.Text(_latin(negocio), style: const pw.TextStyle(fontSize: 10)),
          pw.Row(
            children: [
              logoPdf(_ladoLogo),
              pw.SizedBox(width: 8),
              pw.Text(
                _latin(reporte.titulo),
                style: const pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Text(_latin(subtitulo)),
          pw.SizedBox(height: 12),
          pw.Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              for (final c in reporte.cifras)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      _latin(c.titulo),
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      _latin(c.valor),
                      style: const pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (c.detalle.isNotEmpty)
                      pw.Text(
                        _latin(c.detalle),
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: [for (final c in reporte.columnas) _latin(c)],
            data: [
              for (final fila in reporte.filas)
                [for (final c in fila) _latin(c)],
            ],
            headerStyle: const pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignments: {
              for (final i in reporte.numericas) i: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );
    return doc.save();
  }

  // The built-in PDF font only has Latin-1; swap the few symbols outside it.
  static String _latin(String texto) => texto
      .replaceAll('−', '-')
      .replaceAll('≈', '~')
      .replaceAll('—', '-')
      .replaceAll('–', '-');
}
