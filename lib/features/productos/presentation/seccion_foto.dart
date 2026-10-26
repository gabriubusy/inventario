import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/domain/tamano_imagen.dart';
import 'package:inventario/features/productos/presentation/foto_editable.dart';
import 'package:inventario/features/productos/presentation/foto_producto.dart';

/// Optional photo of the product: preview plus choose (Alt+F) and remove.
class SeccionFoto extends StatelessWidget {
  const SeccionFoto({
    super.key,
    required this.foto,
    required this.fotos,
    required this.nombre,
  });

  static const _lado = 112.0;

  final FotoEditable foto;
  final GestorFotos fotos;

  /// Shown as the initial while there is no photo.
  final String nombre;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return ListenableBuilder(
      listenable: foto,
      builder: (context, _) => Row(
        spacing: espaciado.md,
        children: [
          FotoProducto(
            fotos: fotos,
            imagenId: foto.id,
            nombre: nombre,
            lado: _lado,
            tamano: TamanoImagen.completa,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: espaciado.xs,
              children: [
                // Excluded from Tab/Enter: Alt+F reaches it from any field.
                ExcludeFocus(
                  child: OutlinedButton(
                    onPressed: foto.cargando ? null : foto.elegir,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: espaciado.sm,
                      children: [
                        Text(
                          foto.cargando
                              ? 'Preparando foto…'
                              : foto.id == null
                              ? 'Elegir foto'
                              : 'Cambiar foto',
                        ),
                        TeclaAtajo('Alt+F', color: colores.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                if (foto.id != null)
                  ExcludeFocus(
                    child: TextButton(
                      onPressed: foto.quitar,
                      child: const Text('Quitar foto'),
                    ),
                  ),
                Text(
                  foto.noValida
                      ? 'Ese archivo no es una imagen. Usa una foto JPG, PNG o WebP.'
                      : 'Opcional · JPG, PNG o WebP',
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: foto.noValida
                        ? colores.error
                        : colores.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
