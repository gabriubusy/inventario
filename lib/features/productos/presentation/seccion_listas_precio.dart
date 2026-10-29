import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/precio_en_lista.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/fila_regla_precio.dart';
import 'package:inventario/features/productos/presentation/lote_editable.dart';
import 'package:inventario/features/productos/presentation/reglas_editables.dart';

/// Mayor and Especial prices of the product, with what each brand ends at.
class SeccionListasPrecio extends StatelessWidget {
  const SeccionListasPrecio({
    super.key,
    required this.reglas,
    required this.lotes,
    required this.forma,
  });

  final ReglasEditables reglas;
  final List<LoteEditable> lotes;
  final FormaConteo forma;

  String _queda(ListaPrecio lista) {
    final regla = reglas.filas[lista]!.leer();
    if (regla == null) return '';
    // Only the rule matters to the price; the rest is filler.
    final producto = Producto(
      id: '',
      nombre: '',
      categoria: Categoria.values.first,
      forma: forma,
      minimo: 0,
      reglas: {lista: regla},
    );
    return [
      for (final fila in lotes)
        if (!fila.vacio)
          if (precioDeLote(producto, fila.leer(forma), lista) case final p?)
            '${fila.marca.text.trim()} ${formatearDolares(p)}',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    return ListenableBuilder(
      listenable: Listenable.merge([
        reglas.cambios,
        for (final lote in lotes) lote.cambios,
      ]),
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.espaciado.sm,
        children: [
          Row(
            spacing: context.espaciado.md,
            children: [
              Text(
                'Listas de precios',
                style: tema.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  reglas.abierta
                      ? 'Detal es el precio de cada marca · sin regla vale '
                            'Detal'
                      : 'Mayor y Especial venden a precio Detal',
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: colores.onSurfaceVariant,
                  ),
                ),
              ),
              if (reglas.abierta)
                TeclaAtajo('Alt+L', color: colores.onSurfaceVariant)
              else
                ExcludeFocus(
                  child: TextButton(
                    onPressed: reglas.abrir,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: context.espaciado.sm,
                      children: [
                        const Text('Poner precios'),
                        TeclaAtajo('Alt+L', color: colores.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (reglas.abierta)
            for (final lista in ListaPrecio.conRegla)
              FilaReglaPrecio(
                lista: lista,
                regla: reglas.filas[lista]!,
                unidad: forma.unidad,
                queda: switch (_queda(lista)) {
                  '' => '',
                  final texto => 'Queda $texto',
                },
                onTipo: (tipo) => reglas.elegir(lista, tipo),
              ),
        ],
      ),
    );
  }
}
