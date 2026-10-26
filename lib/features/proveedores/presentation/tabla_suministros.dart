import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/proveedores/domain/suministro.dart';

/// "Productos que trae": product, brand and current stock of each lot.
class TablaSuministros extends StatelessWidget {
  const TablaSuministros({super.key, required this.suministros});

  static const _anchoMarca = 120.0;
  static const _anchoHay = 220.0;

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
              Expanded(child: Text('PRODUCTO', style: encabezado)),
              SizedBox(
                width: _anchoMarca,
                child: Text('MARCA', style: encabezado),
              ),
              SizedBox(
                width: _anchoHay,
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
                    child: Text(
                      s.producto.nombre,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: _anchoMarca,
                    child: Text(s.lote.marca, style: tema.textTheme.bodySmall),
                  ),
                  SizedBox(
                    width: _anchoHay,
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
