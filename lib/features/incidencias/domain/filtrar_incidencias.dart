import 'package:inventario/core/texto.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';

/// Matches by supplier, product or brand; [soloAbiertas] hides answered ones.
List<Incidencia> filtrarIncidencias(
  List<Incidencia> incidencias, {
  String texto = '',
  bool soloAbiertas = false,
}) {
  final buscado = normalizarParaBusqueda(texto);
  bool coincide(Incidencia i) => [
    i.proveedor,
    i.producto,
    i.marca,
  ].any((t) => normalizarParaBusqueda(t).contains(buscado));
  return [
    for (final incidencia in incidencias)
      if ((!soloAbiertas || incidencia.abierta) &&
          (buscado.isEmpty || coincide(incidencia)))
        incidencia,
  ];
}

/// Incidents of one supplier, matched by name like brand lots are.
List<Incidencia> incidenciasDe(String proveedor, List<Incidencia> todas) {
  final clave = normalizarParaBusqueda(proveedor);
  return [
    for (final incidencia in todas)
      if (normalizarParaBusqueda(incidencia.proveedor) == clave) incidencia,
  ];
}
