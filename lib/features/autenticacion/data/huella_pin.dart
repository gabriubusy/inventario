import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// PBKDF2-HMAC-SHA256 of a PIN with its own salt, stored as
/// "pbkdf2-sha256$iterations$salt$hash" so the digits are never kept.
/// A 4-digit PIN can still be guessed by brute force; this only stops it
/// from being read straight from the disk.
abstract final class HuellaPin {
  static const _prefijo = 'pbkdf2-sha256';
  static const _iteraciones = 20000;
  static const _bytesSal = 16;

  static String crear(String pin, {Random? azar}) {
    final generador = azar ?? Random.secure();
    final sal = Uint8List.fromList(
      List.generate(_bytesSal, (_) => generador.nextInt(256)),
    );
    final hash = pbkdf2(utf8.encode(pin), sal, _iteraciones);
    return [
      _prefijo,
      _iteraciones,
      base64Encode(sal),
      base64Encode(hash),
    ].join(r'$');
  }

  /// False as well for a damaged or unknown format.
  static bool coincide(String pin, String huella) {
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
