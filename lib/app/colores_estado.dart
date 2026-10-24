import 'package:flutter/material.dart';

/// Stock alert colors; always shown next to a text label, never alone.
@immutable
class ColoresEstado extends ThemeExtension<ColoresEstado> {
  const ColoresEstado({
    required this.fondoBajo,
    required this.textoBajo,
    required this.barraBajo,
    required this.fondoAgotado,
    required this.textoAgotado,
    required this.barraAgotado,
  });

  static const normal = ColoresEstado(
    fondoBajo: Color(0xFFFDF1D8),
    textoBajo: Color(0xFF7A4B00),
    barraBajo: Color(0xFFB7791F),
    fondoAgotado: Color(0xFFFBE9E7),
    textoAgotado: Color(0xFF8C1D18),
    barraAgotado: Color(0xFFB3261E),
  );

  final Color fondoBajo;
  final Color textoBajo;
  final Color barraBajo;
  final Color fondoAgotado;
  final Color textoAgotado;
  final Color barraAgotado;

  @override
  ColoresEstado copyWith({
    Color? fondoBajo,
    Color? textoBajo,
    Color? barraBajo,
    Color? fondoAgotado,
    Color? textoAgotado,
    Color? barraAgotado,
  }) {
    return ColoresEstado(
      fondoBajo: fondoBajo ?? this.fondoBajo,
      textoBajo: textoBajo ?? this.textoBajo,
      barraBajo: barraBajo ?? this.barraBajo,
      fondoAgotado: fondoAgotado ?? this.fondoAgotado,
      textoAgotado: textoAgotado ?? this.textoAgotado,
      barraAgotado: barraAgotado ?? this.barraAgotado,
    );
  }

  @override
  ColoresEstado lerp(ColoresEstado? other, double t) {
    if (other == null) return this;
    Color mezclar(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return ColoresEstado(
      fondoBajo: mezclar(fondoBajo, other.fondoBajo),
      textoBajo: mezclar(textoBajo, other.textoBajo),
      barraBajo: mezclar(barraBajo, other.barraBajo),
      fondoAgotado: mezclar(fondoAgotado, other.fondoAgotado),
      textoAgotado: mezclar(textoAgotado, other.textoAgotado),
      barraAgotado: mezclar(barraAgotado, other.barraAgotado),
    );
  }
}

extension ColoresEstadoDelTema on BuildContext {
  ColoresEstado get coloresEstado =>
      Theme.of(this).extension<ColoresEstado>() ?? ColoresEstado.normal;
}
