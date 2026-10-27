import 'package:flutter/services.dart';

/// Alt+1… pick the packs when the product has them, else the brands.
const teclasDigito = [
  (LogicalKeyboardKey.digit1, 'Alt+1'),
  (LogicalKeyboardKey.digit2, 'Alt+2'),
  (LogicalKeyboardKey.digit3, 'Alt+3'),
  (LogicalKeyboardKey.digit4, 'Alt+4'),
  (LogicalKeyboardKey.digit5, 'Alt+5'),
  (LogicalKeyboardKey.digit6, 'Alt+6'),
  (LogicalKeyboardKey.digit7, 'Alt+7'),
  (LogicalKeyboardKey.digit8, 'Alt+8'),
  (LogicalKeyboardKey.digit9, 'Alt+9'),
];

/// Brands move to letters when packs take the digits. P and K stay free
/// for the way of selling.
const teclasLetra = [
  (LogicalKeyboardKey.keyQ, 'Alt+Q'),
  (LogicalKeyboardKey.keyW, 'Alt+W'),
  (LogicalKeyboardKey.keyE, 'Alt+E'),
  (LogicalKeyboardKey.keyR, 'Alt+R'),
  (LogicalKeyboardKey.keyT, 'Alt+T'),
  (LogicalKeyboardKey.keyY, 'Alt+Y'),
];
