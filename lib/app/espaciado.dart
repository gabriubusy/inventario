import 'package:flutter/material.dart';

/// Fixed spacing scale so every screen breathes the same way.
@immutable
class Espaciado extends ThemeExtension<Espaciado> {
  const Espaciado({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  static const normal = Espaciado(
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    xxl: 32,
  );

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  @override
  Espaciado copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return Espaciado(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  Espaciado lerp(Espaciado? other, double t) {
    if (other == null) return this;
    double mezclar(double a, double b) => a + (b - a) * t;
    return Espaciado(
      xs: mezclar(xs, other.xs),
      sm: mezclar(sm, other.sm),
      md: mezclar(md, other.md),
      lg: mezclar(lg, other.lg),
      xl: mezclar(xl, other.xl),
      xxl: mezclar(xxl, other.xxl),
    );
  }
}

extension EspaciadoDelTema on BuildContext {
  Espaciado get espaciado =>
      Theme.of(this).extension<Espaciado>() ?? Espaciado.normal;
}
