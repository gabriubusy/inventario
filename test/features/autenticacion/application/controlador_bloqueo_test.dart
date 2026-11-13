import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/autenticacion/application/controlador_bloqueo.dart';
import 'package:inventario/features/autenticacion/data/almacen_bloqueo_en_memoria.dart';

void main() {
  test('it never locks on its own until it is chosen', () async {
    final controlador = ControladorBloqueo(AlmacenBloqueoEnMemoria());
    await controlador.cargar();
    expect(controlador.minutos, 0);
    expect(controlador.espera, isNull);
    controlador.dispose();
  });

  test('the chosen minutes are the wait', () async {
    final controlador = ControladorBloqueo(AlmacenBloqueoEnMemoria());
    await controlador.cargar();
    await controlador.cambiar(15);
    expect(controlador.espera, const Duration(minutes: 15));
    controlador.dispose();
  });

  test('what was chosen comes back on the next start', () async {
    final almacen = AlmacenBloqueoEnMemoria();
    final primero = ControladorBloqueo(almacen);
    await primero.cargar();
    await primero.cambiar(30);
    primero.dispose();

    final segundo = ControladorBloqueo(almacen);
    await segundo.cargar();
    expect(segundo.minutos, 30);
    segundo.dispose();
  });

  test('a time that is not offered is ignored', () async {
    final controlador = ControladorBloqueo(AlmacenBloqueoEnMemoria());
    await controlador.cargar();
    await controlador.cambiar(7);
    expect(controlador.minutos, 0);
    controlador.dispose();
  });
}
