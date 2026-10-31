import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/proveedores/domain/suministro.dart';

/// "Productos que trae": product, brand and current stock of each lot.
class TablaSuministros extends StatelessWidget {
  const TablaSuministros({super.key, required this.suministros});

  // Shares of the width, so a narrow sheet squeezes every column alike.
  static const _flexProducto = 3;
  static const _flexMarca = 2;
  static const _flexHay = 3;

  final List<Suministro> suministros;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final encabezado = tema.textTheme.labelSmall?.copyWith(
      color: colores.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: espaciado.sm),
          child: Row(
            children: [
              Expanded(
                flex: _flexProducto,
                child: Text('PRODUCTO', style: encabezado),
              ),
              Expanded(
                flex: _flexMarca,
                child: Text('MARCA', style: encabezado),
              ),
              Expanded(
                flex: _flexHay,
                child: Text(
                  'HAY AHORA',
                  textAlign: TextAlign.right,
                  style: encabezado,
                ),
              ),
            ],
          ),
        ),
        for (final s in suministros)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colores.outlineVariant)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: espaciado.md),
              child: Row(
                children: [
                  Expanded(
                    flex: _flexProducto,
                    child: Text(
                      s.producto.nombre,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: _flexMarca,
                    child: Text(s.lote.marca, style: tema.textTheme.bodySmall),
                  ),
                  Expanded(
                    flex: _flexHay,
                    child: Text(
                      textoLote(s.producto, s.lote),
                      textAlign: TextAlign.right,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
