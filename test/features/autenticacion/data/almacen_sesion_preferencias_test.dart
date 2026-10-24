import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/autenticacion/data/almacen_sesion_preferencias.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  const ana = Usuario(id: '1', nombre: 'Ana');

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('reads nothing when no session was saved', () async {
    expect(await AlmacenSesionPreferencias().leer(), isNull);
  });

  test('a new instance reads the saved user', () async {
    await AlmacenSesionPreferencias().guardar(ana);
    expect(await AlmacenSesionPreferencias().leer(), ana);
  });

  test('clearing removes the saved user', () async {
    final almacen = AlmacenSesionPreferencias();
    await almacen.guardar(ana);
    await almacen.borrar();
    expect(await almacen.leer(), isNull);
  });
}
