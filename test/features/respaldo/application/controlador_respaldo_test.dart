import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/configuracion/data/almacen_ajustes_respaldo_en_memoria.dart';
import 'package:inventario/features/configuracion/domain/ajustes_respaldo.dart';
import 'package:inventario/features/respaldo/application/controlador_respaldo.dart';
import 'package:inventario/features/respaldo/domain/archivo_respaldo.dart';
import 'package:inventario/features/respaldo/domain/gestor_respaldos.dart';
import 'package:inventario/features/respaldo/domain/resultado_respaldo.dart';

class _GestorFalso implements GestorRespaldos {
  final carpetas = <String>[];

  @override
  bool get disponible => true;

  @override
  Future<ResultadoRespaldo> respaldar(
    String carpeta, {
    required DateTime fecha,
    String prefijo = 'inventario',
  }) async {
    if (carpeta == 'E:') return CarpetaNoDisponible(carpeta);
    carpetas.add(carpeta);
    return RespaldoGuardado(ruta: '$carpeta/x.inventario', bytes: 10);
  }

  @override
  Future<List<ArchivoRespaldo>> enCarpeta(String carpeta) async => const [];

  @override
  Future<ResultadoRespaldo> prepararRestauracion(
    String archivo, {
    required DateTime fecha,
  }) async => const RestauracionPreparada(copiaDeAntes: 'antes');

  @override
  void cerrarApp() {}
}

void main() {
  final ahora = DateTime(2026, 10, 29, 15, 12);
  late _GestorFalso gestor;
  late AlmacenAjustesRespaldoEnMemoria almacen;
  late ControladorRespaldo respaldo;

  setUp(() async {
    gestor = _GestorFalso();
    almacen = AlmacenAjustesRespaldoEnMemoria();
    respaldo = ControladorRespaldo(gestor, almacen, ahora: () => ahora);
    await respaldo.cargar();
  });

  tearDown(() => respaldo.dispose());

  test('a backup remembers its folder and when it was made', () async {
    expect(respaldo.hayQueRecordar, isTrue);
    await respaldo.respaldar(carpeta: 'D:/Respaldos');
    expect(respaldo.ajustes.carpeta, 'D:/Respaldos');
    expect(respaldo.ajustes.ultimo, ahora);
    expect(respaldo.hayQueRecordar, isFalse);
    expect((await almacen.leer()).carpeta, 'D:/Respaldos');
  });

  test('the next one goes to the saved folder', () async {
    await respaldo.cambiarCarpeta('D:/Respaldos');
    await respaldo.respaldar();
    expect(gestor.carpetas, ['D:/Respaldos']);
  });

  test('a missing folder changes nothing', () async {
    final resultado = await respaldo.respaldar(carpeta: 'E:');
    expect(resultado, isA<CarpetaNoDisponible>());
    expect(respaldo.ajustes, const AjustesRespaldo());
  });

  test('"Mañana" hides the reminder today', () async {
    await respaldo.posponer();
    expect(respaldo.hayQueRecordar, isFalse);
  });
}
