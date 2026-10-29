import 'package:inventario/features/respaldo/domain/archivo_respaldo.dart';
import 'package:inventario/features/respaldo/domain/gestor_respaldos.dart';
import 'package:inventario/features/respaldo/domain/resultado_respaldo.dart';

/// The browser build: there is no file to copy, so it only says so.
class GestorRespaldosNoDisponible implements GestorRespaldos {
  const GestorRespaldosNoDisponible();

  @override
  bool get disponible => false;

  @override
  Future<ResultadoRespaldo> respaldar(
    String carpeta, {
    required DateTime fecha,
    String prefijo = 'inventario',
  }) async => const RespaldoNoDisponibleAqui();

  @override
  Future<List<ArchivoRespaldo>> enCarpeta(String carpeta) async => const [];

  @override
  Future<ResultadoRespaldo> prepararRestauracion(
    String archivo, {
    required DateTime fecha,
  }) async => const RespaldoNoDisponibleAqui();

  @override
  void cerrarApp() {}
}
