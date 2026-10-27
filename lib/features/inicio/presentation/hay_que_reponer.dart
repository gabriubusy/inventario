import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/productos/domain/por_reponer.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/etiqueta_estado.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// Sold-out and low products with who brings them, to order or receive.
class HayQueReponer extends StatelessWidget {
  const HayQueReponer({super.key, required this.productos});

  final List<Producto> productos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    const cifras = [FontFeature.tabularFigures()];
    final suave = tema.textTheme.bodySmall?.copyWith(
      color: colores.onSurfaceVariant,
      fontFeatures: cifras,
    );
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(espaciado.lg),
            child: Row(
              spacing: espaciado.sm,
              children: [
                Expanded(
                  child: Text(
                    'Hay que reponer',
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'Pedir',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: colores.onSurfaceVariant,
                  ),
                ),
                TeclaAtajo('F2', color: colores.onSurfaceVariant),
              ],
            ),
          ),
          if (productos.isEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                espaciado.lg,
                0,
                espaciado.lg,
                espaciado.lg,
              ),
              child: Text('Todo está por encima del mínimo.', style: suave),
            ),
          for (final producto in productos)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colores.outlineVariant)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: espaciado.lg,
                  vertical: espaciado.sm + 2,
                ),
                child: Row(
                  spacing: espaciado.md,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tema.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            proveedoresDe(producto)
                                .join(', ')
                                .ifEmpty('Sin proveedor'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: suave,
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: textoPrincipal(producto),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: ' / ${textoCantidadMinima(producto)}',
                            style: suave,
                          ),
                        ],
                      ),
                      style: tema.textTheme.bodyMedium?.copyWith(
                        fontFeatures: cifras,
                      ),
                    ),
                    EtiquetaEstado(producto.estado),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension on String {
  String ifEmpty(String otro) => isEmpty ? otro : this;
}
