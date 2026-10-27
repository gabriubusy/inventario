import 'package:inventario/core/fechas.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/kardex/domain/linea_kardex.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';

/// How far back the kardex looks.
enum PeriodoKardex {
  hoy('Hoy', 0),
  semana('Últimos 7 días', 6),
  mes('Últimos 30 días', 29),
  todo('Todo', null);

  const PeriodoKardex(this.etiqueta, this.dias);

  final String etiqueta;

  /// Days before today included; null means no limit.
  final int? dias;

  bool incluye(DateTime fecha, DateTime hoy) {
    final dias = this.dias;
    return dias == null || diasEntre(fecha, hoy) <= dias;
  }
}

/// Keeps the rows of [grupo] (all when null) within [periodo]. Filtering
/// after computing the balance keeps each row's balance right.
List<LineaKardex> filtrarKardex(
  List<LineaKardex> lineas, {
  GrupoMovimiento? grupo,
  PeriodoKardex periodo = PeriodoKardex.semana,
  required DateTime hoy,
}) => [
  for (final l in lineas)
    if ((grupo == null || l.movimiento.tipo.grupo == grupo) &&
        periodo.incluye(l.movimiento.fecha, hoy))
      l,
];

/// Same brand, ignoring case and accents.
bool esDeMarca(String marca, String buscada) =>
    normalizarParaBusqueda(marca) == normalizarParaBusqueda(buscada);
