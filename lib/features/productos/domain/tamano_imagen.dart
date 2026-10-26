/// Sizes every product photo is kept in.
enum TamanoImagen {
  completa(800),
  miniatura(200);

  const TamanoImagen(this.ladoMaximo);

  /// Longest side in pixels; also the `cacheWidth` hint for display.
  final int ladoMaximo;
}
