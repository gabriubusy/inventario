import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/listas.dart';

void main() {
  test('lists with the same elements in order are equal', () {
    expect(listasIguales([1, 2, 3], [1, 2, 3]), isTrue);
    expect(listasIguales(<int>[], <int>[]), isTrue);
  });

  test('order and length matter', () {
    expect(listasIguales([1, 2], [2, 1]), isFalse);
    expect(listasIguales([1, 2], [1, 2, 3]), isFalse);
  });
}
