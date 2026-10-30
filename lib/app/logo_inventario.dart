import 'package:flutter/material.dart';
import 'package:inventario/core/marca.dart';

/// The app's mark. Drawn, not an image, so it stays sharp at any size.
class LogoInventario extends StatelessWidget {
  const LogoInventario({super.key, this.tamano = 40});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Inventario',
      image: true,
      child: SizedBox.square(
        dimension: tamano,
        child: const CustomPaint(painter: _PintorLogo()),
      ),
    );
  }
}

class _PintorLogo extends CustomPainter {
  const _PintorLogo();

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.shortestSide / Marca.rejilla;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(Marca.radioFondo * u),
      ),
      Paint()..color = const Color(Marca.granate),
    );
    for (final caja in Marca.cajas) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(caja.x * u, caja.y * u, caja.ancho * u, caja.alto * u),
          Radius.circular(Marca.radioCaja * u),
        ),
        Paint()..color = Color(caja.color),
      );
    }
  }

  @override
  bool shouldRepaint(_PintorLogo oldDelegate) => false;
}
