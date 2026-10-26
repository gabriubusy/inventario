import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/application/estado_existencias.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/tarjeta_producto.dart';

/// A sliver, so it must sit inside a [CustomScrollView].
class GrillaProductos extends StatelessWidget {
  const GrillaProductos({
    super.key,
    required this.estado,
    required this.productos,
  });

  static const _anchoTarjeta = 320.0;
  static const _altoTarjeta = 180.0;

  final EstadoExistencias estado;
  final List<Producto> productos;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    if (estado is CargandoExistencias) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (productos.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: espaciado.xxl),
          child: Text(
            'No hay productos que coincidan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _anchoTarjeta,
        mainAxisExtent: _altoTarjeta,
        crossAxisSpacing: espaciado.md,
        mainAxisSpacing: espaciado.md,
      ),
      itemCount: productos.length,
      itemBuilder: (context, i) => TarjetaProducto(productos[i]),
    );
  }
}
