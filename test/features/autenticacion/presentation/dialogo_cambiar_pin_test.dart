import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/data/almacen_sesion_en_memoria.dart';
import 'package:inventario/features/autenticacion/data/repositorio_autenticacion_en_memoria.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/resultado_inicio_sesion.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';
import 'package:inventario/features/autenticacion/presentation/dialogo_cambiar_pin.dart';

void main() {
  late RepositorioAutenticacionEnMemoria repositorio;
  late ControladorSesion sesion;

  setUp(() {
    repositorio = RepositorioAutenticacionEnMemoria((
      usuario: const Usuario(id: '1', nombre: 'Ana'),
      pin: Pin.tryParse('1234')!,
    ));
    sesion = ControladorSesion(repositorio, AlmacenSesionEnMemoria());
  });

  tearDown(() => sesion.dispose());

  Future<void> abrir(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  unawaited(mostrarDialogoCambiarPin(context, sesion)),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> teclear(WidgetTester tester, String digitos) async {
    for (final digito in digitos.split('')) {
      await tester.sendKeyEvent(
        LogicalKeyboardKey(LogicalKeyboardKey.digit0.keyId + int.parse(digito)),
      );
    }
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
  }

  Future<bool> abre(String digitos) async =>
      await repositorio.iniciarSesion(pin: Pin.tryParse(digitos)!)
          is InicioSesionCorrecto;

  testWidgets('current, new and repeated: the PIN changes', (tester) async {
    await abrir(tester);
    await teclear(tester, '1234');
    expect(find.text('Escribe el nuevo PIN'), findsOneWidget);
    await teclear(tester, '4826');
    expect(find.text('Repite el nuevo PIN'), findsOneWidget);
    await teclear(tester, '4826');
    await enter(tester);
    expect(find.byType(DialogoCambiarPin), findsNothing);
    expect(find.text('PIN cambiado'), findsOneWidget);
    expect(await abre('4826'), isTrue);
    expect(await abre('1234'), isFalse);
  });

  testWidgets('a repeat that does not match asks again', (tester) async {
    await abrir(tester);
    await teclear(tester, '1234');
    await teclear(tester, '4826');
    await teclear(tester, '4820');
    await enter(tester);
    expect(
      find.text('No coincide con el nuevo PIN. Escríbelo otra vez.'),
      findsOneWidget,
    );
    expect(await abre('1234'), isTrue);
  });

  testWidgets('a wrong current PIN goes back to the first step', (
    tester,
  ) async {
    await abrir(tester);
    await teclear(tester, '9999');
    await teclear(tester, '4826');
    await teclear(tester, '4826');
    await enter(tester);
    expect(find.text('El PIN actual no es correcto.'), findsOneWidget);
    expect(find.text('Escribe tu PIN actual'), findsOneWidget);
    expect(await abre('1234'), isTrue);
  });

  testWidgets('the on-screen keypad works too', (tester) async {
    await abrir(tester);
    for (final digito in ['1', '2', '3', '4']) {
      await tester.tap(find.widgetWithText(OutlinedButton, digito));
    }
    await tester.pumpAndSettle();
    expect(find.text('Escribe el nuevo PIN'), findsOneWidget);
  });
}
