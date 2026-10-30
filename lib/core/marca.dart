/// The logo's shape on a 64-unit grid, shared by the screen and the PDFs:
/// a maroon rounded square holding three boxes in tones.
abstract final class Marca {
  static const rejilla = 64;
  static const radioFondo = 14;
  static const radioCaja = 3;
  static const granate = 0xFF7A1F2B;

  static const List<({int x, int y, int ancho, int alto, int color})> cajas = [
    (x: 22, y: 11, ancho: 20, alto: 18, color: 0xFFE9B8BF),
    (x: 10, y: 32, ancho: 20, alto: 18, color: 0xFFFFFFFF),
    (x: 34, y: 32, ancho: 20, alto: 18, color: 0xFFF4D9DD),
  ];
}
