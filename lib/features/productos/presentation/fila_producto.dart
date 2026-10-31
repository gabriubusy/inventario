import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/seguir_elegido.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/etiqueta_estado.dart';
import 'package:inventario/features/productos/presentation/foto_producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// Column widths shared with the list header.
abstract final class ColumnasProducto {
  static const foto = 40.0;
  static const existencia = 110.0;
  static const precio = 130.0;
  static const minimo = 84.0;
  static const estado = 88.0;
}

class FilaProducto extends StatelessWidget {
  const FilaProducto({
    super.key,
    required this.producto,
    required this.fotos,
    required this.elegido,
    required this.aBolivares,
    required this.onElegir,
  });

  static const _alto = 64.0;

  final Producto producto;
  final GestorFotos fotos;
  final bool elegido;
  final int? Function(int dolares) aBolivares;
  final VoidCallback onElegir;

  String get _subtitulo {
    final marcas = producto.lotes.map((l) => l.marca).toSet().join(' · ');
    return '${producto.categoria.etiqueta} · '
        '${marcas.isEmpty ? 'Sin marcas todavía' : marcas}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final secundario = tema.textTheme.bodySmall?.copyWith(
      color: colores.onSurfaceVariant,
    );
    final fuerte = tema.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final precio = textoPrecio(producto);
    return SeguirElegido(
      elegido: elegido,
      child: Semantics(
        selected: elegido,
        button: true,
        child: InkWell(
          onTap: onElegir,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: elegido ? colores.primary.withValues(alpha: 0.08) : null,
              border: Border(top: BorderSide(color: colores.outlineVariant)),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: _alto),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: espaciado.lg,
                  vertical: espaciado.sm,
                ),
                child: Row(
                  spacing: espaciado.md,
                  children: [
                    FotoProducto(
                      fotos: fotos,
                      imagenId: producto.imagenId,
                      nombre: producto.nombre,
                      lado: ColumnasProducto.foto,
                    ),
                    Expanded(
                      child: _Celda(
                        arriba: producto.nombre,
                        abajo: _subtitulo,
                        estiloArriba: fuerte,
                        estiloAbajo: secundario,
                        alinear: CrossAxisAlignment.start,
                      ),
                    ),
                    SizedBox(
                      width: ColumnasProducto.existencia,
                      child: _Celda(
                        arriba: textoPrincipal(producto),
                        abajo: producto.forma.cuentaPiezas
                            ? producto.forma.unidad.formatear(producto.cantidad)
                            : producto.forma.etiqueta.toLowerCase(),
                        estiloArriba: fuerte,
                        estiloAbajo: secundario,
                      ),
                    ),
                    SizedBox(
                      width: ColumnasProducto.precio,
                      child: _Celda(
                        arriba: precio ?? 'Sin precio',
                        abajo: textoPrecioBs(producto, aBolivares) ?? '',
                        estiloArriba: precio == null ? secundario : fuerte,
                        estiloAbajo: secundario,
                      ),
                    ),
                    SizedBox(
                      width: ColumnasProducto.minimo,
                      child: Text(
                        textoCantidadMinima(producto),
                        textAlign: TextAlign.right,
                        style: secundario,
                      ),
                    ),
                    SizedBox(
                      width: ColumnasProducto.estado,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: producto.estado == EstadoStock.disponible
                            ? Text('OK', style: secundario)
                            : EtiquetaEstado(producto.estado),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Celda extends StatelessWidget {
  const _Celda({
    required this.arriba,
    required this.abajo,
    required this.estiloArriba,
    required this.estiloAbajo,
    this.alinear = CrossAxisAlignment.end,
  });

  final String arriba;
  final String abajo;
  final TextStyle? estiloArriba;
  final TextStyle? estiloAbajo;
  final CrossAxisAlignment alinear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alinear,
      children: [
        Text(
          arriba,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: estiloArriba,
        ),
        if (abajo.isNotEmpty)
          Text(
            abajo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: estiloAbajo,
          ),
      ],
    );
  }
}
