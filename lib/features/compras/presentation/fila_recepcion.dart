import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/entradas/presentation/campo_cantidad_recibida.dart';
import 'package:inventario/features/entradas/presentation/controlador_cantidad.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// What was ordered of one line and a field for what really arrived.
/// Left empty, the line keeps waiting for the supplier.
class FilaRecepcion extends StatelessWidget {
  const FilaRecepcion({
    super.key,
    required this.linea,
    required this.piezas,
    required this.cantidad,
    required this.focoPiezas,
    required this.focoCantidad,
  });

  final LineaCompra linea;
  final TextEditingController piezas;
  final ControladorCantidad cantidad;
  final FocusNode focoPiezas;
  final FocusNode focoCantidad;

  static String _pedido(LineaCompra linea) => [
    if (linea.piezas > 0) textoPiezas(linea.piezas),
    linea.forma.unidad.formatear(linea.cantidad),
  ].join(' · ');

  /// "Cuadra", "−0,6 kg" or "+1 pieza · +1,2 kg"; null while it is empty.
  static String? diferencia(
    LineaCompra linea, {
    required int piezas,
    required int cantidad,
  }) {
    if (piezas <= 0 && cantidad <= 0) return null;
    final llegada = linea.conRecibido(piezas: piezas, cantidad: cantidad);
    if (!llegada.tieneDiferencia) return 'Cuadra';
    String con(int valor, String texto) => valor > 0 ? '+$texto' : '−$texto';
    return [
      if (llegada.diferenciaPiezas != 0)
        con(
          llegada.diferenciaPiezas,
          textoPiezas(llegada.diferenciaPiezas.abs()),
        ),
      if (llegada.diferencia != 0)
        con(
          llegada.diferencia,
          linea.forma.unidad.formatear(llegada.diferencia.abs()),
        ),
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final alertas = context.coloresEstado;
    final espaciado = context.espaciado;
    const cifras = [FontFeature.tabularFigures()];
    final leidas = CampoCantidadRecibida.leer(piezas, 0);
    final llegada = CampoCantidadRecibida.leer(
      cantidad,
      linea.forma.unidad.decimales,
      unidad: linea.forma.unidad,
    );
    final texto = diferencia(linea, piezas: leidas, cantidad: llegada);
    final cuadra = texto == 'Cuadra';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: espaciado.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: espaciado.md,
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(top: espaciado.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    linea.producto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    linea.marca,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: colores.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(top: espaciado.sm),
              child: Text(
                _pedido(linea),
                textAlign: TextAlign.right,
                style: tema.textTheme.bodyMedium?.copyWith(
                  fontFeatures: cifras,
                ),
              ),
            ),
          ),
          if (linea.forma.cuentaPiezas)
            Expanded(
              flex: 2,
              child: CampoCantidadRecibida(
                etiqueta: 'Piezas',
                controller: piezas,
                focusNode: focoPiezas,
                decimales: 0,
                opcional: true,
              ),
            ),
          Expanded(
            flex: 3,
            child: CampoCantidadRecibida(
              etiqueta: linea.forma.cuentaPiezas ? 'Peso' : 'Llegó',
              controller: cantidad,
              focusNode: focoCantidad,
              decimales: linea.forma.unidad.decimales,
              sufijo: linea.forma.unidad.simbolo,
              unidad: linea.forma.unidad,
              opcional: true,
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(top: espaciado.sm),
              child: Text(
                texto ?? 'Sin confirmar',
                textAlign: TextAlign.right,
                style: tema.textTheme.bodyMedium?.copyWith(
                  fontWeight: texto == null ? null : FontWeight.w600,
                  fontFeatures: cifras,
                  color: texto == null
                      ? colores.onSurfaceVariant
                      : cuadra
                      ? alertas.textoBien
                      : alertas.textoBajo,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
