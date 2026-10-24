import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/autenticacion/data/repositorio_autenticacion_en_memoria.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/resultado_inicio_sesion.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';

void main() {
  const ana = Usuario(id: '1', nombre: 'Ana');
  final repositorio = RepositorioAutenticacionEnMemoria((
    usuario: ana,
    pin: Pin.tryParse('1234')!,
  ));

  test('returns the user when the PIN matches', () async {
    final resultado = await repositorio.iniciarSesion(
      pin: Pin.tryParse('1234')!,
    );
    expect(resultado, isA<InicioSesionCorrecto>());
    expect((resultado as InicioSesionCorrecto).usuario, ana);
  });

  test('rejects a wrong PIN', () async {
    final resultado = await repositorio.iniciarSesion(
      pin: Pin.tryParse('4321')!,
    );
    expect(resultado, isA<PinIncorrecto>());
  });
}
