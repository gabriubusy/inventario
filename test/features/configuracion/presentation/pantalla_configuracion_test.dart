import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/configuracion/application/controlador_negocio.dart';
import 'package:inventario/features/configuracion/data/almacen_ajustes_respaldo_en_memoria.dart';
import 'package:inventario/features/configuracion/data/repositorio_negocio_en_memoria.dart';
import 'package:inventario/features/configuracion/presentation/pantalla_configuracion.dart';
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
    carpetas.add(carpeta);
    return RespaldoGuardado(ruta: '$carpeta/x.inventario', bytes: 4404019);
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
  late RepositorioNegocioEnMemoria repositorio;
  late ControladorNegocio negocio;
  late _GestorFalso gestor;
  late ControladorRespaldo respaldo;

  setUp(() async {
    repositorio = RepositorioNegocioEnMemoria();
    negocio = ControladorNegocio(repositorio);
    gestor = _GestorFalso();
    respaldo = ControladorRespaldo(gestor, AlmacenAjustesRespaldoEnMemoria());
    await respaldo.cargar();
  });

  tearDown(() {
    negocio.dispose();
    respaldo.dispose();
  });

  Future<void> abrir(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaConfiguracion(
          negocio: negocio,
          respaldo: respaldo,
          onCambiarPin: () {},
          elegirCarpeta: () async => 'E:/Respaldos',
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> conControl(WidgetTester tester, LogicalKeyboardKey tecla) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(tecla);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
  }

  testWidgets('Ctrl+S saves the shop details', (tester) async {
    await abrir(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'La Esquina',
    );
    await tester.enterText(find.widgetWithText(TextField, 'RIF'), 'J-1');
    await conControl(tester, LogicalKeyboardKey.keyS);
    expect((await repositorio.leer()).nombre, 'La Esquina');
    expect(find.text('Datos del negocio guardados'), findsOneWidget);
  });

  testWidgets('Ctrl+B asks for a folder the first time and remembers it', (
    tester,
  ) async {
    await abrir(tester);
    expect(find.text('Nunca se ha respaldado'), findsOneWidget);
    await conControl(tester, LogicalKeyboardKey.keyB);
    expect(gestor.carpetas, ['E:/Respaldos']);
    expect(find.text('Último: hoy'), findsOneWidget);
    expect(find.textContaining('4,2 MB'), findsOneWidget);
    await conControl(tester, LogicalKeyboardKey.keyB);
    expect(gestor.carpetas, ['E:/Respaldos', 'E:/Respaldos']);
  });
}
