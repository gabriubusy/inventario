import 'package:inventario/core/marca.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The app's mark in a PDF, as vectors, [lado] points wide.
pw.Widget logoPdf(double lado) {
  final u = lado / Marca.rejilla;
  return pw.SizedBox(
    width: lado,
    height: lado,
    child: pw.Stack(
      children: [
        pw.Container(
          width: lado,
          height: lado,
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(Marca.granate),
            borderRadius: pw.BorderRadius.circular(Marca.radioFondo * u),
          ),
        ),
        for (final caja in Marca.cajas)
          pw.Positioned(
            left: caja.x * u,
            top: caja.y * u,
            child: pw.Container(
              width: caja.ancho * u,
              height: caja.alto * u,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(caja.color),
                borderRadius: pw.BorderRadius.circular(Marca.radioCaja * u),
              ),
            ),
          ),
      ],
    ),
  );
}
