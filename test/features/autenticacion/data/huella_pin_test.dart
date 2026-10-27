import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/autenticacion/data/huella_pin.dart';

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  test('matches the published PBKDF2-HMAC-SHA256 test vectors', () {
    final clave = utf8.encode('password');
    final sal = utf8.encode('salt');
    expect(
      _hex(HuellaPin.pbkdf2(clave, sal, 1)),
      '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
    );
    expect(
      _hex(HuellaPin.pbkdf2(clave, sal, 2)),
      'ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43',
    );
  });

  test('the stored print never contains the digits', () {
    final huella = HuellaPin.crear('4826', azar: Random(1));
    expect(huella, isNot(contains('4826')));
    expect(huella, startsWith(r'pbkdf2-sha256$'));
  });

  test('recognises the right PIN and only that one', () {
    final huella = HuellaPin.crear('4826');
    expect(HuellaPin.coincide('4826', huella), isTrue);
    expect(HuellaPin.coincide('4827', huella), isFalse);
  });

  test(
    'the same PIN gives a different print each time, thanks to the salt',
    () {
      expect(HuellaPin.crear('4826'), isNot(HuellaPin.crear('4826')));
    },
  );

  test('a damaged print never lets anyone in', () {
    for (final mala in ['', 'abc', r'pbkdf2-sha256$x$a$b', r'md5$1$a$b']) {
      expect(HuellaPin.coincide('4826', mala), isFalse, reason: mala);
    }
  });
}
