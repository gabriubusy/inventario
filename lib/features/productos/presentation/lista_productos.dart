import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/domain/filtro_estado.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/fila_producto.dart';
import 'package:inventario/features/productos/presentation/lista_productos_vacia.dart';

class ListaProductos extends StatelessWidget {
  const ListaProductos({
    super.key,
    required this.controlador,
    required this.fotos,
    required this.busqueda,
    required this.focoBusqueda,
    required this.aBolivares,
    required this.onCrear,
    required this.onAbrir,
    required this.onLimpiar,
  });

  final ControladorListaProductos controlador;
  final GestorFotos fotos;
  final TextEditingController busqueda;
  final FocusNode focoBusqueda;
  final int? Function(int dolares) aBolivares;

  /// Opens the new product window, prefilled with [nombre] if not empty.
  final ValueChanged<String> onCrear;

  /// Opens the edit window of a clicked product.
  final ValueChanged<Producto> onAbrir;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final productos = controlador.visibles;
    final elegido = controlador.elegido;
    final nota = tema.textTheme.bodySmall?.copyWith(
      color: colores.onSurfaceVariant,
    );
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(espaciado.lg),
            child: Row(
              spacing: espaciado.md,
              children: [
                Expanded(
                  child: TextField(
                    controller: busqueda,
                    focusNode: focoBusqueda,
                    onChanged: controlador.buscar,
                    decoration: const InputDecoration(
                      hintText: 'Buscar producto o marca (Ctrl+K)',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                ExcludeFocus(
                  child: SegmentedButton<FiltroEstado>(
                    showSelectedIcon: false,
                    segments: [
                      for (final filtro in FiltroEstado.values)
                        ButtonSegment(
                          value: filtro,
                          label: Text(filtro.etiqueta),
                        ),
                    ],
                    selected: {controlador.filtro},
                    onSelectionChanged: (elegidos) =>
                        controlador.filtrar(elegidos.first),
                  ),
                ),
              ],
            ),
          ),
          const _Cabecera(),
          Expanded(
            child: productos.isEmpty
                ? ListaProductosVacia(
                    sinProductos: controlador.existencias.productos.isEmpty,
                    busqueda: controlador.busqueda,
                    filtro: controlador.filtro,
                    onCrear: onCrear,
                    onLimpiar: onLimpiar,
                  )
                : ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, i) {
                      final producto = productos[i];
                      return FilaProducto(
                        producto: producto,
                        fotos: fotos,
                        elegido: producto.id == elegido?.id,
                        aBolivares: aBolivares,
                        onElegir: () {
                          controlador.elegir(producto.id);
                          onAbrir(producto);
                        },
                      );
                    },
                  ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colores.outlineVariant)),
            ),
            child: Padding(
              padding: EdgeInsets.all(espaciado.md),
              child: Text(
                '↑ ↓ moverse · Enter editar · F8 kardex · Ctrl+K buscar · Ctrl+T tasa',
                style: nota,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final estilo = tema.textTheme.labelSmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    );
    Widget columna(String texto, double ancho) => SizedBox(
      width: ancho,
      child: Text(texto, textAlign: TextAlign.right, style: estilo),
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: espaciado.lg,
        vertical: espaciado.sm,
      ),
      child: Row(
        spacing: espaciado.md,
        children: [
          const SizedBox(width: ColumnasProducto.foto),
          Expanded(child: Text('PRODUCTO', style: estilo)),
          columna('EXISTENCIA', ColumnasProducto.existencia),
          columna('PRECIO', ColumnasProducto.precio),
          columna('MÍNIMO', ColumnasProducto.minimo),
          columna('ESTADO', ColumnasProducto.estado),
        ],
      ),
    );
  }
}
