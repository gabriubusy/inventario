import 'package:inventario/core/fechas.dart';

/// The six reports of F12, Alt+1–6 in this order.
enum TipoReporte {
  ventas('Ventas'),
  ganancia('Ganancia'),
  masVendidos('Más vendidos'),
  inventario('Inventario valorizado'),
  cuentas('Cuentas por pagar'),
  gastos('Gastos');

  const TipoReporte(this.etiqueta);

  final String etiqueta;
}

/// How far back a report looks; Alt+P cycles them.
enum PeriodoReporte {
  hoy('Hoy'),
  semana('Últimos 7 días'),
  mes('Este mes'),
  treintaDias('Últimos 30 días'),
  todo('Todo');

  const PeriodoReporte(this.etiqueta);

  final String etiqueta;

  bool incluye(DateTime fecha, DateTime dia) => switch (this) {
    PeriodoReporte.hoy => diasEntre(fecha, dia) == 0,
    semana => diasEntre(fecha, dia) <= 6,
    mes => fecha.year == dia.year && fecha.month == dia.month,
    treintaDias => diasEntre(fecha, dia) <= 29,
    todo => true,
  };
}

/// A key figure on top of a report.
typedef CifraReporte = ({String titulo, String valor, String detalle});

/// A report ready to show, print or export: figures, then a table whose
/// cells are already formatted text.
class Reporte {
  const Reporte({
    required this.titulo,
    required this.cifras,
    required this.columnas,
    required this.filas,
    this.numericas = const {},
  });

  final String titulo;
  final List<CifraReporte> cifras;
  final List<String> columnas;
  final List<List<String>> filas;

  /// Indexes of the columns aligned to the right.
  final Set<int> numericas;
}
