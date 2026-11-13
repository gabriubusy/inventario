import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// PBKDF2-HMAC-SHA256 of a PIN with its own salt, stored as
/// "pbkdf2-sha256$iterations$salt$hash" so the digits are never kept.
/// Only 10.000 PINs exist, so whoever copies the file can still try them
/// all: the rounds below just make that slower, and what really guards the
/// app is the wait after a wrong PIN. Each print carries the rounds it was
/// made with, so older ones still open and get rewritten on the way in.
abstract final class HuellaPin {
  static const _prefijo = 'pbkdf2-sha256';

  /// Around a third of a second on this kind of computer, off the UI
  /// isolate; more would be felt every time the app is unlocked.
  static const iteraciones = 100000;
  static const _bytesSal = 16;

  /// On another isolate: the rounds would freeze the login otherwise.
  static Future<String> crear(String pin, {Random? azar}) =>
      _fuera(() => crearAhora(pin, azar: azar));

  static Future<bool> coincide(String pin, String huella) =>
      _fuera(() => coincideAhora(pin, huella));

  /// The rounds the print was made with; null if it cannot be read.
  static int? iteracionesDe(String huella) {
    final partes = huella.split(r'$');
    if (partes.length != 4 || partes[0] != _prefijo) return null;
    return int.tryParse(partes[1]);
  }

  // Isolates are not a thing on the web build, where it runs as it comes.
  static Future<T> _fuera<T>(T Function() trabajo) =>
      kIsWeb ? Future.value(trabajo()) : Isolate.run(trabajo);

  /// [rondas] only for tests and for reading what an older version wrote.
  static String crearAhora(
    String pin, {
    Random? azar,
    int rondas = iteraciones,
  }) {
    final generador = azar ?? Random.secure();
    final sal = Uint8List.fromList(
      List.generate(_bytesSal, (_) => generador.nextInt(256)),
    );
    final hash = pbkdf2(utf8.encode(pin), sal, rondas);
    return [_prefijo, rondas, base64Encode(sal), base64Encode(hash)].join(r'$');
  }

  /// False as well for a damaged or unknown format.
  static bool coincideAhora(String pin, String huella) {
    final partes = huella.split(r'$');
    if (partes.length != 4 || partes[0] != _prefijo) return false;
    final iteraciones = int.tryParse(partes[1]);
    if (iteraciones == null || iteraciones < 1) return false;
    final List<int> sal;
    final List<int> esperado;
    try {
      sal = base64Decode(partes[2]);
      esperado = base64Decode(partes[3]);
    } on FormatException {
      return false;
    }
    final obtenido = pbkdf2(utf8.encode(pin), sal, iteraciones);
    return _iguales(obtenido, esperado);
  }

  /// One 32-byte block, which is all SHA-256 gives per round (RFC 8018).
  static List<int> pbkdf2(List<int> clave, List<int> sal, int iteraciones) {
    final hmac = Hmac(sha256, clave);
    var u = hmac.convert([...sal, 0, 0, 0, 1]).bytes;
    final resultado = Uint8List.fromList(u);
    for (var i = 1; i < iteraciones; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < resultado.length; j++) {
        resultado[j] ^= u[j];
      }
    }
    return resultado;
  }

  // Compares every byte so the time taken does not reveal where it differs.
  static bool _iguales(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diferencia = 0;
    for (var i = 0; i < a.length; i++) {
      diferencia |= a[i] ^ b[i];
    }
    return diferencia == 0;
  }
}
