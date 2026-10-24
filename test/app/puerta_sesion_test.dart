import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/app.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/data/almacen_sesion_en_memoria.dart';
import 'package:inventario/features/autenticacion/data/repositorio_autenticacion_en_memoria.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';

void main() {
  late ControladorSesion sesion;
  late ControladorExistencias existencias;

  setUp(() async {
    sesion = ControladorSesion(
      RepositorioAutenticacionEnMemoria((
        usuario: const Usuario(id: '1', nombre: 'Ana'),
        pin: Pin.tryParse('1234')!,
      )),
      AlmacenSesionEnMemoria(),
    );
    existencias = ControladorExistencias(
      const RepositorioProductosEnMemoria([]),
    );
    await existencias.cargar();
  });

  tearDown(() {
    sesion.dispose();
    existencias.dispose();
  });

  Future<void> entrar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      InventarioApp(
        controladorSesion: sesion,
        controladorExistencias: existencias,
      ),
    );
    for (final digito in ['1', '2', '3', '4']) {
      await tester.tap(find.widgetWithText(OutlinedButton, digito));
    }
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the home screen after entering the PIN', (tester) async {
    await entrar(tester);
    expect(find.text('Existencias'), findsOneWidget);
  });

  testWidgets('locking goes back to the PIN screen', (tester) async {
    await entrar(tester);
    await tester.tap(find.text('Bloquear'));
    await tester.pumpAndSettle();
    expect(find.text('Introduce tu PIN'), findsOneWidget);
  });

  testWidgets('Ctrl+L locks from the keyboard', (tester) async {
    await entrar(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.text('Introduce tu PIN'), findsOneWidget);
  });
}
