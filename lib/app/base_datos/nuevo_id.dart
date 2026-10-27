import 'dart:math';

final _azar = Random();

/// A short id unique enough for one shop: time plus a random tail, so two
/// rows made in the same microsecond still differ.
String nuevoId(String prefijo) {
  final tiempo = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final cola = _azar.nextInt(1 << 20).toRadixString(36).padLeft(4, '0');
  return '$prefijo$tiempo$cola';
}
