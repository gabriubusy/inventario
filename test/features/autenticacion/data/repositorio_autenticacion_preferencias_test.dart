import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/autenticacion/data/repositorio_autenticacion_preferencias.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/resultado_cambio_pin.dart';
import 'package:inventario/features/autenticacion/domain/resultado_inicio_sesion.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  const ana = Usuario(id: '1', nombre: 'Ana');
  final inicial = Pin.tryParse('1234')!;
  final nuevo = Pin.tryParse('4826')!;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  RepositorioAutenticacionPreferencias crear() =>
      RepositorioAutenticacionPreferencias(usuario: ana, pinInicial: inicial);

  test('the first PIN works until it is changed', () async {
    expect(
      await crear().iniciarSesion(pin: inicial),
      isA<InicioSesionCorrecto>(),
    );
  });

  test('after a change only the new PIN opens, also after a restart', () async {
    final resultado = await crear().cambiarPin(actual: inicial, nuevo: nuevo);
    expect(resultado, isA<PinCambiado>());
    final otraVez = crear();
    expect(
      await otraVez.iniciarSesion(pin: nuevo),
      isA<InicioSesionCorrecto>(),
    );
    expect(await otraVez.iniciarSesion(pin: inicial), isA<PinIncorrecto>());
  });

  test('a wrong current PIN changes nothing', () async {
    final resultado = await crear().cambiarPin(actual: nuevo, nuevo: nuevo);
    expect(resultado, isA<PinActualIncorrecto>());
    expect(
      await crear().iniciarSesion(pin: inicial),
      isA<InicioSesionCorrecto>(),
    );
  });

  test('the device keeps a hash, never the digits', () async {
    await crear().cambiarPin(actual: inicial, nuevo: nuevo);
    final guardado = await SharedPreferencesAsync().getString(
      'autenticacion.huellaPin',
    );
    expect(guardado, isNot(contains('4826')));
  });
}
