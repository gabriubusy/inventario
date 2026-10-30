import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';
import 'package:inventario/features/salidas/presentation/opcion_tarjeta.dart';

/// "Saco · Alt+1" per pack of [producto], for its label's hover help.
String ayudaPresentaciones(Producto producto) => lineasAyuda(
  [for (final p in producto.presentaciones) p.nombre],
  [for (var i = 1; i <= producto.presentaciones.length; i++) 'Alt+$i'],
).join('\n');

/// One card per pack with its price.
class OpcionesPresentacionSalida extends StatelessWidget {
  const OpcionesPresentacionSalida({
    super.key,
    required this.producto,
    required this.elegida,
    required this.onElegir,
  });

  static const _columnas = 2;

  final Producto producto;
  final Presentacion? elegida;
  final ValueChanged<Presentacion> onElegir;

  String _detalle(Presentacion p) {
    final unidad = producto.forma.unidad;
    if (p.factor == unidad.fraccionesPorUnidad) {
      return 'por ${unidad.simbolo} suelto';
    }
    return '${p.nombre.toLowerCase()} de ${unidad.formatear(p.factor)}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return LayoutBuilder(
      builder: (context, limites) {
        final ancho =
            (limites.maxWidth - espaciado.sm * (_columnas - 1)) / _columnas;
        return Wrap(
          spacing: espaciado.sm,
          runSpacing: espaciado.sm,
          children: [
            for (final p in producto.presentaciones)
              SizedBox(
                width: ancho,
                child: OpcionTarjeta(
                  elegida: p == elegida,
                  onPulsar: () => onElegir(p),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: espaciado.xs / 2,
                    children: [
                      Text(
                        p.predeterminada ? '${p.nombre} ★' : p.nombre,
                        style: tema.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        formatearDolares(p.precio),
                        style: tema.textTheme.titleMedium?.copyWith(
                          color: colores.primary,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        _detalle(p),
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: colores.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
