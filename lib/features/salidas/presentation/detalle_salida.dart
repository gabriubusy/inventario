import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';
import 'package:inventario/features/salidas/domain/medida_venta.dart';
import 'package:inventario/features/salidas/domain/modo_venta.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/presentation/opciones_marca_salida.dart';
import 'package:inventario/features/salidas/presentation/opciones_presentacion_salida.dart';
import 'package:inventario/features/salidas/presentation/seccion_cantidad_salida.dart';
import 'package:inventario/features/salidas/presentation/selector_modo_venta.dart';

/// Pack, brand and way of selling of the chosen product.
class DetalleSalida extends StatelessWidget {
  const DetalleSalida({
    super.key,
    required this.producto,
    required this.presentacion,
    required this.lote,
    required this.modo,
    required this.teclasMarca,
    required this.onPresentacion,
    required this.onLote,
    required this.onModo,
  });

  final Producto producto;

  /// Null when the product has no packs.
  final Presentacion? presentacion;

  /// Index of the chosen brand lot; null when none has stock.
  final int? lote;
  final ModoVenta? modo;
  final List<String> teclasMarca;
  final ValueChanged<Presentacion> onPresentacion;
  final ValueChanged<int> onLote;
  final ValueChanged<ModoVenta> onModo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final modo = this.modo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.espaciado.lg,
      children: [
        if (producto.presentaciones.isNotEmpty)
          ConEtiqueta(
            etiqueta: 'Presentación',
            child: ExcludeFocus(
              child: OpcionesPresentacionSalida(
                producto: producto,
                elegida: presentacion,
                onElegir: onPresentacion,
              ),
            ),
          ),
        if (lote == null)
          Text(
            producto.lotes.isEmpty
                ? 'No hay existencias de este producto.'
                : 'Ninguna marca tiene existencias para venderse así.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.error,
            ),
          )
        else
          ConEtiqueta(
            etiqueta: 'Marca',
            child: ExcludeFocus(
              child: OpcionesMarcaSalida(
                producto: producto,
                elegido: lote,
                onElegir: onLote,
                atajos: teclasMarca,
              ),
            ),
          ),
        if (modo != null)
          ConEtiqueta(
            etiqueta: 'Cómo se vende',
            child: ExcludeFocus(
              child: SelectorModoVenta(elegido: modo, onElegir: onModo),
            ),
          ),
      ],
    );
  }
}

/// How much, its amount and an optional note; Enter in either submits.
class CantidadYNota extends StatelessWidget {
  const CantidadYNota({
    super.key,
    required this.producto,
    required this.lote,
    required this.modo,
    required this.medida,
    required this.cantidad,
    required this.focoCantidad,
    required this.nota,
    required this.salida,
    required this.aBolivares,
    required this.onEnviar,
  });

  final Producto producto;
  final LoteMarca lote;
  final ModoVenta? modo;
  final MedidaVenta medida;
  final TextEditingController cantidad;
  final FocusNode focoCantidad;
  final TextEditingController nota;
  final Salida? Function() salida;
  final int? Function(int dolares) aBolivares;
  final VoidCallback onEnviar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.espaciado.lg,
      children: [
        SeccionCantidadSalida(
          producto: producto,
          lote: lote,
          modo: modo,
          medida: medida,
          controller: cantidad,
          focusNode: focoCantidad,
          salida: salida,
          aBolivares: aBolivares,
          onEnviar: onEnviar,
        ),
        TextFormField(
          controller: nota,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nota (opcional)',
            hintText: 'Cliente, despacho, observaciones…',
          ),
          onFieldSubmitted: (_) => onEnviar(),
        ),
      ],
    );
  }
}
