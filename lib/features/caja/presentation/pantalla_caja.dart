import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/caja/application/controlador_caja.dart';
import 'package:inventario/features/caja/domain/movimientos_caja.dart';
import 'package:inventario/features/caja/presentation/abrir_caja.dart';
import 'package:inventario/features/caja/presentation/dialogo_cerrar_caja.dart';
import 'package:inventario/features/caja/presentation/lista_movimientos_caja.dart';
import 'package:inventario/features/caja/presentation/saldos_caja.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/gastos/presentation/dialogo_gasto.dart';
import 'package:inventario/features/movimientos/presentation/textos_movimiento.dart';

/// F11: what there should be of each way of paying, every money movement
/// of the day, and the close-out (Ctrl+S).
class PantallaCaja extends StatefulWidget {
  const PantallaCaja({super.key, required this.caja, required this.gastos});

  static const _anchoMaximo = 1240.0;
  static const _anchoSaldos = 400.0;

  final ControladorCaja caja;
  final ControladorGastos gastos;

  @override
  State<PantallaCaja> createState() => _PantallaCajaState();
}

class _PantallaCajaState extends State<PantallaCaja> {
  @override
  void initState() {
    super.initState();
    // Sales are read again so the till shows the latest ones.
    unawaited(widget.caja.cargar());
  }

  void _gasto() =>
      unawaited(mostrarDialogoGasto(context, gastos: widget.gastos));

  void _cerrar() {
    if (widget.caja.abierta == null) return;
    unawaited(mostrarDialogoCerrarCaja(context, caja: widget.caja));
  }

  String? get _resumenAnterior {
    final ultima = widget.caja.ultimaCerrada;
    final cerrada = ultima?.cerrada;
    if (ultima == null || cerrada == null) return null;
    return 'La última se cerró el '
        '${formatearFechaCorta(cerrada, widget.caja.hoy).toLowerCase()} '
        'a las ${textoHora(cerrada)}'
        '${ultima.nota.isEmpty ? '' : ' · ${ultima.nota}'}';
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final espaciado = context.espaciado;
    return AtajosDeTeclado(
      atajos: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            unawaited(Navigator.of(context).maybePop()),
        const SingleActivator(LogicalKeyboardKey.keyG, control: true): _gasto,
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): _cerrar,
      },
      child: ListenableBuilder(
        listenable: Listenable.merge([widget.caja, widget.gastos]),
        builder: (context, _) {
          final abierta = widget.caja.abierta;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                abierta == null
                    ? 'Caja cerrada'
                    : 'Caja · abierta desde las ${textoHora(abierta.abierta)}',
              ),
              actions: [
                TextButton(
                  onPressed: _gasto,
                  child: Row(
                    spacing: espaciado.sm,
                    children: [
                      const Text('Gasto o ingreso'),
                      TeclaAtajo('Ctrl+G', color: colores.onSurfaceVariant),
                    ],
                  ),
                ),
                if (abierta != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: espaciado.md),
                    child: FilledButton(
                      onPressed: _cerrar,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                      ),
                      child: Row(
                        spacing: espaciado.sm,
                        children: [
                          const Text('Cerrar caja'),
                          TeclaAtajo('Ctrl+S', color: colores.onPrimary),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            body: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: PantallaCaja._anchoMaximo,
                ),
                child: ListView(
                  padding: EdgeInsets.all(espaciado.xl),
                  children: [
                    if (abierta == null)
                      AbrirCaja(
                        resumenAnterior: _resumenAnterior,
                        onAbrir: ({required dolares, required bolivares}) =>
                            unawaited(
                              widget.caja.abrir(
                                fondoDolares: dolares,
                                fondoBolivares: bolivares,
                              ),
                            ),
                      )
                    else
                      Builder(
                        builder: (context) {
                          final movimientos = widget.caja.movimientosDe(
                            abierta,
                          );
                          final saldos = saldosDeCaja(movimientos);
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: espaciado.xl,
                            children: [
                              SizedBox(
                                width: PantallaCaja._anchoSaldos,
                                child: SaldosCaja(
                                  saldos: saldos,
                                  total: totalEnDolares(
                                    saldos,
                                    widget.caja.tasaDeHoy,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListaMovimientosCaja(
                                  movimientos: movimientos,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
