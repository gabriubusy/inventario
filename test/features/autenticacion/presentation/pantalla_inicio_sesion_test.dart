import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/application/estado_sesion.dart';
import 'package:inventario/features/autenticacion/data/almacen_sesion_en_memoria.dart';
import 'package:inventario/features/autenticacion/data/repositorio_autenticacion_en_memoria.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';
import 'package:inventario/features/autenticacion/presentation/indicador_pin.dart';
import 'package:inventario/features/autenticacion/presentation/pantalla_inicio_sesion.dart';

void main() {
  late ControladorSesion controlador;

  setUp(() {
    controlador = ControladorSesion(
      RepositorioAutenticacionEnMemoria((
        usuario: const Usuario(id: '1', nombre: 'Ana'),
        pin: Pin.tryParse('1234')!,
      )),
      AlmacenSesionEnMemoria(),
    );
  });

  tearDown(() => controlador.dispose());

  Future<void> mostrar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaInicioSesion(controlador: controlador),
      ),
    );
  }

  Future<void> teclear(WidgetTester tester, String digitos) async {
    for (final digito in digitos.split('')) {
      await tester.tap(find.widgetWithText(OutlinedButton, digito));
    }
    await tester.pump();
  }

  int introducidos(WidgetTester tester) =>
      tester.widget<IndicadorPin>(find.byType(IndicadorPin)).introducidos;

  Finder botonEntrar() => find.widgetWithText(FilledButton, 'Entrar');

  bool entrarHabilitado(WidgetTester tester) =>
      tester.widget<FilledButton>(botonEntrar()).onPressed != null;

  testWidgets('fills one dot per digit and stops at four', (tester) async {
    await mostrar(tester);
    await teclear(tester, '12');
    expect(introducidos(tester), 2);

    await teclear(tester, '3456');
    expect(introducidos(tester), Pin.longitud);
  });

  testWidgets('enables Entrar only with the full PIN', (tester) async {
    await mostrar(tester);
    await teclear(tester, '123');
    expect(entrarHabilitado(tester), isFalse);

    await teclear(tester, '4');
    expect(entrarHabilitado(tester), isTrue);
  });

  testWidgets('deletes the last digit', (tester) async {
    await mostrar(tester);
    await teclear(tester, '12');
    await tester.tap(find.byTooltip('Borrar'));
    await tester.pump();
    expect(introducidos(tester), 1);
  });

  testWidgets('opens the session with the right PIN', (tester) async {
    await mostrar(tester);
    await teclear(tester, '1234');
    await tester.tap(botonEntrar());
    await tester.pumpAndSettle();
    expect(controlador.estado, isA<SesionAbierta>());
  });

  testWidgets('shows an error and resets the dots on a wrong PIN', (
    tester,
  ) async {
    await mostrar(tester);
    await teclear(tester, '9999');
    await tester.tap(botonEntrar());
    await tester.pumpAndSettle();

    expect(find.text('PIN incorrecto'), findsOneWidget);
    expect(introducidos(tester), 0);

    await teclear(tester, '1');
    expect(find.text('PIN incorrecto'), findsNothing);
  });

  testWidgets('accepts the PIN from the physical keyboard', (tester) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.sendKeyEvent(LogicalKeyboardKey.numpad2);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(controlador.estado, isA<SesionAbierta>());
  });
}
