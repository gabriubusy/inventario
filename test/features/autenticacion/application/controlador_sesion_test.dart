import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/application/estado_sesion.dart';
import 'package:inventario/features/autenticacion/data/almacen_sesion_en_memoria.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/repositorio_autenticacion.dart';
import 'package:inventario/features/autenticacion/domain/resultado_inicio_sesion.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';

/// Answers with whatever completer the test hands it.
class _RepositorioFalso implements RepositorioAutenticacion {
  Completer<ResultadoInicioSesion> respuesta = Completer();
  int llamadas = 0;

  @override
  Future<ResultadoInicioSesion> iniciarSesion({required Pin pin}) {
    llamadas++;
    return respuesta.future;
  }
}

void main() {
  const ana = Usuario(id: '1', nombre: 'Ana');
  late _RepositorioFalso repositorio;
  late AlmacenSesionEnMemoria almacen;
  late ControladorSesion controlador;

  setUp(() {
    repositorio = _RepositorioFalso();
    almacen = AlmacenSesionEnMemoria();
    controlador = ControladorSesion(repositorio, almacen);
  });

  tearDown(() => controlador.dispose());

  Future<void> iniciar() =>
      controlador.iniciarSesion(pin: Pin.tryParse('1234')!);

  test('starts with the session closed and no error', () {
    final estado = controlador.estado;
    expect(estado, isA<SesionCerrada>());
    expect((estado as SesionCerrada).pinIncorrecto, isFalse);
  });

  test('is logging in while the repository answers', () {
    unawaited(iniciar());
    expect(controlador.estado, isA<IniciandoSesion>());
  });

  test('opens the session when the PIN is right', () async {
    final enCurso = iniciar();
    repositorio.respuesta.complete(const InicioSesionCorrecto(ana));
    await enCurso;
    final estado = controlador.estado;
    expect(estado, isA<SesionAbierta>());
    expect((estado as SesionAbierta).usuario, ana);
  });

  test('flags a wrong PIN and keeps the session closed', () async {
    final enCurso = iniciar();
    repositorio.respuesta.complete(const PinIncorrecto());
    await enCurso;
    final estado = controlador.estado;
    expect(estado, isA<SesionCerrada>());
    expect((estado as SesionCerrada).pinIncorrecto, isTrue);
  });

  test('ignores a second attempt while one is in progress', () async {
    final primero = iniciar();
    unawaited(iniciar());
    repositorio.respuesta.complete(const InicioSesionCorrecto(ana));
    await primero;
    expect(repositorio.llamadas, 1);
  });

  test('closing the session clears the user', () async {
    final enCurso = iniciar();
    repositorio.respuesta.complete(const InicioSesionCorrecto(ana));
    await enCurso;
    controlador.cerrarSesion();
    expect(controlador.estado, isA<SesionCerrada>());
  });

  test('saves the session when the PIN is right', () async {
    final enCurso = iniciar();
    repositorio.respuesta.complete(const InicioSesionCorrecto(ana));
    await enCurso;
    expect(await almacen.leer(), ana);
  });

  test('does not save the session when the PIN is wrong', () async {
    final enCurso = iniciar();
    repositorio.respuesta.complete(const PinIncorrecto());
    await enCurso;
    expect(await almacen.leer(), isNull);
  });

  test('restores a saved session after a reload', () async {
    await almacen.guardar(ana);
    await controlador.restaurar();
    final estado = controlador.estado;
    expect(estado, isA<SesionAbierta>());
    expect((estado as SesionAbierta).usuario, ana);
  });

  test('stays closed when there is no saved session', () async {
    await controlador.restaurar();
    expect(controlador.estado, isA<SesionCerrada>());
  });

  test('locking forgets the saved session', () async {
    await almacen.guardar(ana);
    await controlador.restaurar();
    controlador.cerrarSesion();
    await pumpEventQueue();
    expect(await almacen.leer(), isNull);
  });
}
