import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/productos/domain/filtro_estado.dart';

/// No products yet, or none matching: always offers the next step.
class ListaProductosVacia extends StatelessWidget {
  const ListaProductosVacia({
    super.key,
    required this.sinProductos,
    required this.busqueda,
    required this.filtro,
    required this.onCrear,
    required this.onLimpiar,
  });

  final bool sinProductos;
  final String busqueda;
  final FiltroEstado filtro;
  final ValueChanged<String> onCrear;
  final VoidCallback onLimpiar;

  String get _nombreSugerido {
    final texto = busqueda.trim();
    if (texto.isEmpty) return '';
    return texto[0].toUpperCase() + texto.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final sugerido = _nombreSugerido;
    final titulo = sinProductos
        ? 'Aún no tienes productos'
        : sugerido.isNotEmpty
        ? 'No hay productos con “${busqueda.trim()}”'
        : 'Ningún producto en “${filtro.etiqueta}”';
    final detalle = sinProductos
        ? 'Crea el primero para empezar a registrar entradas y salidas.'
        : 'Se busca por nombre y marca, sin importar tildes.';
    return Center(
      child: Padding(
        padding: EdgeInsets.all(espaciado.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: espaciado.md,
          children: [
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: colores.onSurfaceVariant,
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: espaciado.sm,
              runSpacing: espaciado.sm,
              children: [
                FilledButton(
                  onPressed: () => onCrear(sinProductos ? '' : sugerido),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: espaciado.sm,
                    children: [
                      Text(
                        sugerido.isEmpty || sinProductos
                            ? 'Crear producto'
                            : 'Crear “$sugerido”',
                      ),
                      TeclaAtajo('Ctrl+N', color: colores.onPrimary),
                    ],
                  ),
                ),
                if (!sinProductos)
                  OutlinedButton(
                    onPressed: onLimpiar,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: espaciado.sm,
                      children: [
                        const Text('Limpiar'),
                        TeclaAtajo('Esc', color: colores.onSurfaceVariant),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
