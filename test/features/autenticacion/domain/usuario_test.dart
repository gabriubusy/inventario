import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';

void main() {
  const usuario = Usuario(id: '1', nombre: 'Ana');

  test('users with the same data are equal', () {
    const copia = Usuario(id: '1', nombre: 'Ana');
    expect(usuario, copia);
    expect(usuario.hashCode, copia.hashCode);
  });

  test('copyWith changes only the given fields', () {
    final renombrado = usuario.copyWith(nombre: 'Ana María');
    expect(renombrado.nombre, 'Ana María');
    expect(renombrado.id, usuario.id);
    expect(renombrado, isNot(usuario));
  });
}
