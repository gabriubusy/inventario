import 'package:inventario/features/reportes/domain/reporte.dart';

/// Turns a report into a file the user keeps or prints.
abstract interface class ExportadorReportes {
  /// Opens the system print dialog, where it can also be saved as PDF.
  Future<void> pdf(Reporte reporte, {required String subtitulo});

  /// Saves a CSV that Excel opens; false when the user cancelled.
  Future<bool> csv(Reporte reporte, {required String nombre});
}
