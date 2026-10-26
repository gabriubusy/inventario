import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/domain/tamano_imagen.dart';

/// A product photo, or the name's initial while there is none.
class FotoProducto extends StatefulWidget {
  const FotoProducto({
    super.key,
    required this.fotos,
    required this.imagenId,
    required this.nombre,
    required this.lado,
    this.tamano = TamanoImagen.miniatura,
  });

  final GestorFotos fotos;
  final String? imagenId;
  final String nombre;
  final double lado;
  final TamanoImagen tamano;

  @override
  State<FotoProducto> createState() => _FotoProductoState();
}

class _FotoProductoState extends State<FotoProducto> {
  Future<Uint8List?>? _bytes;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(FotoProducto anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.imagenId != widget.imagenId ||
        anterior.tamano != widget.tamano) {
      _cargar();
    }
  }

  void _cargar() {
    final id = widget.imagenId;
    _bytes = id == null ? null : widget.fotos.leer(id, widget.tamano);
  }

  @override
  Widget build(BuildContext context) {
    final sinFoto = _SinFoto(nombre: widget.nombre, lado: widget.lado);
    final pixeles = (widget.lado * MediaQuery.devicePixelRatioOf(context))
        .round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.espaciado.sm),
      child: SizedBox.square(
        dimension: widget.lado,
        child: FutureBuilder(
          future: _bytes,
          builder: (context, datos) {
            final bytes = datos.data;
            if (bytes == null) return sinFoto;
            return Image.memory(
              bytes,
              fit: BoxFit.cover,
              cacheWidth: pixeles,
              gaplessPlayback: true,
              semanticLabel: 'Foto de ${widget.nombre}',
              errorBuilder: (_, _, _) => sinFoto,
            );
          },
        ),
      ),
    );
  }
}

class _SinFoto extends StatelessWidget {
  const _SinFoto({required this.nombre, required this.lado});

  final String nombre;
  final double lado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final inicial = nombre.trim().isEmpty ? '' : nombre.trim()[0].toUpperCase();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surfaceContainerLowest,
        border: Border.all(color: colores.outlineVariant),
        borderRadius: BorderRadius.circular(context.espaciado.sm),
      ),
      child: Center(
        child: inicial.isEmpty
            ? Icon(
                Icons.image_outlined,
                size: lado * 0.4,
                color: colores.onSurfaceVariant,
              )
            : Text(
                inicial,
                style: tema.textTheme.titleMedium?.copyWith(
                  fontSize: lado * 0.4,
                  color: colores.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
