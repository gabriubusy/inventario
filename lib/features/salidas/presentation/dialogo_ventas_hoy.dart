import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/domain/devolver_venta.dart';
import 'package:inventario/features/salidas/domain/resultado_anulacion.dart';
import 'package:inventario/features/salidas/presentation/confirmar_anulacion.dart';
import 'package:inventario/features/salidas/presentation/fila_venta_hoy.dart';

Future<void> mostrarVentasDeHoy(
  BuildContext context, {
  required ControladorMovimientos movimientos,
  required ControladorSalidas salidas,
  required ControladorExistencias existencias,
}) => showDialog<void>(
  context: context,
  builder: (_) => DialogoVentasHoy(
    movimientos: movimientos,
    salidas: salidas,
    existencias: existencias,
  ),
);

/// Today's sales, newest first. ↑ ↓ pick one, Supr cancels it after asking.
class DialogoVentasHoy extends StatefulWidget {
  const DialogoVentasHoy({
    super.key,
    required this.movimientos,
    required this.salidas,
    required this.existencias,
  });

  static const _ancho = 760.0;
  static const _altoLista = 460.0;

  final ControladorMovimientos movimientos;
  final ControladorSalidas salidas;
  final ControladorExistencias existencias;

  @override
  State<DialogoVentasHoy> createState() => _DialogoVentasHoyState();
}

class _DialogoVentasHoyState extends State<DialogoVentasHoy> {
  var _elegida = 0;
  var _anulando = false;

  List<Movimiento> get _ventas => widget.movimientos.ventasDeHoy;

  void _mover(int pasos) {
    final total = _ventas.length;
    if (total == 0) return;
    setState(() => _elegida = (_elegida + pasos).clamp(0, total - 1));
  }

  /// How the product would be left once the goods are back.
  String? _quedara(Movimiento venta) {
    final producto = widget.existencias.productos
        .where((p) => p.id == venta.productoId)
        .firstOrNull;
    if (producto == null) return null;
    return textoStock(
      devolverVenta(
        producto,
        marca: venta.marca,
        proveedor: venta.proveedor,
        piezas: venta.piezas,
        cantidad: venta.cantidad,
        abrioPieza: venta.abrioPieza,
      ),
    );
  }

  Future<void> _anular(Movimiento venta) async {
    if (_anulando || venta.anulada) return;
    final mensajero = ScaffoldMessenger.of(context);
    final confirmada = await confirmarAnulacion(
      context,
      venta: venta,
      quedara: _quedara(venta),
    );
    if (!confirmada || !mounted) return;
    setState(() => _anulando = true);
    final resultado = await widget.salidas.anular(venta);
    if (!mounted) return;
    setState(() => _anulando = false);
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(switch (resultado) {
            VentaAnulada() =>
              'Venta anulada · se devolvieron '
                  '${venta.forma.unidad.formatear(venta.cantidad)} '
                  'de ${venta.producto}',
            YaAnulada() => 'Esa venta ya estaba anulada',
            AnulacionSinProducto() =>
              'No se pudo anular: el producto ya no existe',
          }),
        ),
      );
  }

  void _anularElegida() {
    final ventas = _ventas;
    if (_elegida < ventas.length) unawaited(_anular(ventas[_elegida]));
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    const SingleActivator(LogicalKeyboardKey.arrowUp): () => _mover(-1),
    const SingleActivator(LogicalKeyboardKey.arrowDown): () => _mover(1),
    const SingleActivator(LogicalKeyboardKey.delete): _anularElegida,
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: _atajos,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DialogoVentasHoy._ancho),
          child: Padding(
            padding: EdgeInsets.all(espaciado.xl),
            child: ListenableBuilder(
              listenable: widget.movimientos,
              builder: (context, _) {
                final ventas = _ventas;
                final validas = ventas.where((v) => !v.anulada);
                final total = validas.fold(0, (t, v) => t + (v.importe ?? 0));
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: espaciado.md,
                  children: [
                    const EncabezadoDialogo(
                      titulo: 'Ventas de hoy',
                      icono: Icons.receipt_long_outlined,
                    ),
                    Text(
                      '${validas.length} ventas · ${formatearDolares(total)} · '
                      '↑ ↓ elegir · Supr anular',
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                    if (ventas.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: espaciado.xl),
                        child: Text(
                          'Aún no hay ventas hoy.',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.bodyLarge,
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: DialogoVentasHoy._altoLista,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: ventas.length,
                          itemBuilder: (context, i) => FilaVentaHoy(
                            venta: ventas[i],
                            elegida: i == _elegida,
                            onElegir: () => setState(() => _elegida = i),
                            onAnular: () => unawaited(_anular(ventas[i])),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
