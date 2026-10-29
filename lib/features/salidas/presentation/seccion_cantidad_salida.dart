import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/domain/medida_venta.dart';
import 'package:inventario/features/salidas/domain/modo_venta.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/domain/vender.dart';
import 'package:inventario/features/salidas/presentation/campo_cantidad_vendida.dart';
import 'package:inventario/features/salidas/presentation/importe_salida.dart';
import 'package:inventario/features/salidas/presentation/vista_previa_salida.dart';

/// The amount, what it costs and how the stock is left, all live.
class SeccionCantidadSalida extends StatelessWidget {
  const SeccionCantidadSalida({
    super.key,
    required this.producto,
    required this.lote,
    required this.modo,
    required this.medida,
    required this.controller,
    required this.focusNode,
    required this.salida,
    required this.aBolivares,
    required this.onEnviar,
    this.lista = ListaPrecio.detal,
  });

  final Producto producto;
  final LoteMarca lote;
  final ModoVenta? modo;
  final MedidaVenta medida;
  final TextEditingController controller;
  final FocusNode focusNode;

  /// The sale the fields describe; null until it is complete.
  final Salida? Function() salida;
  final int? Function(int dolares) aBolivares;
  final VoidCallback onEnviar;

  /// The ticket's price list.
  final ListaPrecio lista;

  /// "kg" when the pack is the unit itself, else the pack's name.
  String _sufijo({required bool plural}) => switch (medida) {
    MedidaEnUnidad(:final unidad) => unidad.simbolo,
    MedidaEnPresentacion(:final presentacion) => _nombre(presentacion, plural),
  };

  String _nombre(Presentacion presentacion, bool plural) {
    final unidad = producto.forma.unidad;
    if (presentacion.factor == unidad.fraccionesPorUnidad) {
      return unidad.simbolo;
    }
    final nombre = presentacion.nombre.trim().toLowerCase();
    if (!plural) return nombre;
    return RegExp('[aeiouáéíóú]\$').hasMatch(nombre)
        ? '${nombre}s'
        : '${nombre}es';
  }

  int? get _precio => medida.precio(producto, lote, lista);

  /// "$ 5,33 /kg (Mayor)"; the list is named only when it isn't Detal.
  String? get _porUnidad {
    final precio = _precio;
    if (precio == null) return null;
    final enLista = lista == ListaPrecio.detal ? '' : ' (${lista.etiqueta})';
    return '${formatearDolares(precio)} /${_sufijo(plural: false)}$enLista';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final escrito = CampoCantidadVendida.leer(controller, medida.decimales);
        final uno = escrito == _uno;
        final venta = salida();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: context.espaciado.lg,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.espaciado.lg,
              children: [
                Expanded(
                  child: CampoCantidadVendida(
                    etiqueta: modo == ModoVenta.piezaEntera
                        ? 'Peso de la pieza (en la balanza)'
                        : 'Cantidad',
                    controller: controller,
                    focusNode: focusNode,
                    decimales: medida.decimales,
                    sufijo: _sufijo(plural: !uno),
                    disponible: medida.desdeBase(
                      disponibleParaVender(lote, modo),
                    ),
                    onEnviar: onEnviar,
                  ),
                ),
                Expanded(
                  child: ImporteSalida(
                    porUnidad: _porUnidad,
                    cantidad: escrito <= 0
                        ? null
                        : '${formatDecimal(escrito, decimales: medida.decimales)}'
                              ' ${_sufijo(plural: !uno)}',
                    importe: medida.importe(escrito, _precio),
                    aBolivares: aBolivares,
                  ),
                ),
              ],
            ),
            if (venta != null)
              VistaPreviaSalida(producto: producto, salida: venta),
          ],
        );
      },
    );
  }

  /// One whole unit, scaled like the field.
  int get _uno {
    var uno = 1;
    for (var i = 0; i < medida.decimales; i++) {
      uno *= 10;
    }
    return uno;
  }
}
