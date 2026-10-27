import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/ajustes/application/controlador_ajustes.dart';
import 'package:inventario/features/ajustes/presentation/dialogo_ajuste.dart';
import 'package:inventario/features/caja/application/controlador_caja.dart';
import 'package:inventario/features/caja/presentation/pantalla_caja.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/presentation/dialogo_compra.dart';
import 'package:inventario/features/compras/presentation/pantalla_cuentas.dart';
import 'package:inventario/features/conteo/application/controlador_conteo.dart';
import 'package:inventario/features/conteo/presentation/pantalla_conteo.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/entradas/presentation/aviso_entrada.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/gastos/presentation/dialogo_gasto.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/presentation/dialogo_incidencia.dart';
import 'package:inventario/features/incidencias/presentation/pantalla_incidencias.dart';
import 'package:inventario/features/inicio/presentation/accion_rapida.dart';
import 'package:inventario/features/inicio/presentation/acciones_rapidas.dart';
import 'package:inventario/features/inicio/presentation/barra_superior.dart';
import 'package:inventario/features/inicio/presentation/panel_del_dia.dart';
import 'package:inventario/features/kardex/presentation/pantalla_kardex.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/presentation/cabecera_existencias.dart';
import 'package:inventario/features/productos/presentation/dialogo_nuevo_producto.dart';
import 'package:inventario/features/productos/presentation/grilla_productos.dart';
import 'package:inventario/features/productos/presentation/pantalla_productos.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/presentation/pantalla_proveedores.dart';
import 'package:inventario/features/reportes/data/exportador_archivos.dart';
import 'package:inventario/features/reportes/domain/exportador_reportes.dart';
import 'package:inventario/features/reportes/presentation/pantalla_reportes.dart';
import 'package:inventario/features/salidas/application/controlador_devoluciones.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/presentation/aviso_salida.dart';
import 'package:inventario/features/salidas/presentation/dialogo_salida.dart';
import 'package:inventario/features/salidas/presentation/dialogo_ventas_hoy.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/presentation/aviso_tasa.dart';
import 'package:inventario/features/tasa/presentation/dialogo_tasa.dart';
import 'package:inventario/features/tasa/presentation/pedir_tasa_si_falta.dart';

/// Counter home: quick actions, the day at a glance, then live stock.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({
    super.key,
    required this.controlador,
    required this.proveedores,
    required this.entradas,
    required this.salidas,
    required this.incidencias,
    required this.movimientos,
    required this.compras,
    required this.gastos,
    required this.caja,
    this.exportador = const ExportadorArchivos(),
    required this.ajustes,
    required this.conteo,
    required this.devoluciones,
    required this.listaProductos,
    required this.tasa,
    required this.fotos,
    required this.onBloquear,
    required this.onCambiarPin,
  });

  static const _anchoMaximo = 1240.0;

  final ControladorExistencias controlador;
  final ControladorProveedores proveedores;
  final ControladorEntradas entradas;
  final ControladorSalidas salidas;
  final ControladorIncidencias incidencias;
  final ControladorMovimientos movimientos;
  final ControladorCompras compras;
  final ControladorGastos gastos;
  final ControladorCaja caja;
  final ExportadorReportes exportador;
  final ControladorAjustes ajustes;
  final ControladorConteo conteo;
  final ControladorDevoluciones devoluciones;
  final ControladorListaProductos listaProductos;
  final ControladorTasa tasa;
  final GestorFotos fotos;
  final VoidCallback onBloquear;
  final VoidCallback onCambiarPin;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final _focoBusqueda = FocusNode();

  /// Ctrl+Z undoes whichever of entry or sale happened last.
  AccionRapida? _ultimoMovimiento;

  @override
  void initState() {
    super.initState();
    widget.entradas.addListener(_alCambiarEntradas);
    widget.salidas.addListener(_alCambiarSalidas);
  }

  @override
  void dispose() {
    widget.entradas.removeListener(_alCambiarEntradas);
    widget.salidas.removeListener(_alCambiarSalidas);
    _focoBusqueda.dispose();
    super.dispose();
  }

  void _alCambiarEntradas() {
    if (widget.entradas.puedeDeshacer) _ultimoMovimiento = AccionRapida.entrada;
  }

  void _alCambiarSalidas() {
    if (widget.salidas.puedeDeshacer) _ultimoMovimiento = AccionRapida.salida;
  }

  void _ejecutar(AccionRapida accion) {
    switch (accion) {
      case AccionRapida.salida:
        _registrarSalida();
      case AccionRapida.entrada:
        _registrarEntrada();
      case AccionRapida.productos:
        _abrirProductos();
      case AccionRapida.merma:
        unawaited(
          mostrarDialogoAjuste(
            context,
            ajustes: widget.ajustes,
            existencias: widget.controlador,
          ),
        );
    }
  }

  void _registrarEntrada() => unawaited(
    mostrarDialogoCompra(
      context,
      compras: widget.compras,
      existencias: widget.controlador,
      proveedores: widget.proveedores.nombres,
      aBolivares: widget.tasa.aBolivares,
    ),
  );

  void _abrirCaja() => unawaited(
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaCaja(caja: widget.caja, gastos: widget.gastos),
      ),
    ),
  );

  void _abrirReportes() => unawaited(
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaReportes(
          movimientos: widget.movimientos,
          existencias: widget.controlador,
          compras: widget.compras,
          gastos: widget.gastos,
          exportador: widget.exportador,
        ),
      ),
    ),
  );

  void _registrarGasto() =>
      unawaited(mostrarDialogoGasto(context, gastos: widget.gastos));

  void _abrirCuentas() => unawaited(
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaCuentas(
          compras: widget.compras,
          aBolivares: widget.tasa.aBolivares,
        ),
      ),
    ),
  );

  void _registrarSalida() => unawaited(_venderConTasa());

  /// Without today's rate there is no selling: ask for it first, then sell.
  Future<void> _venderConTasa() async {
    if (!widget.tasa.esDeHoy) {
      await mostrarDialogoTasa(context, widget.tasa);
      if (!mounted || !widget.tasa.esDeHoy) return;
    }
    await mostrarDialogoSalida(
      context,
      salidas: widget.salidas,
      existencias: widget.controlador,
      aBolivares: widget.tasa.aBolivares,
    );
  }

  void _deshacerMovimiento() {
    // Inside a text field Ctrl+Z undoes the typing, not the movement.
    final foco = FocusManager.instance.primaryFocus?.context?.widget;
    if (foco is EditableText) return;
    final mensajero = ScaffoldMessenger.of(context);
    final salida = widget.salidas.puedeDeshacer;
    final entrada = widget.entradas.puedeDeshacer;
    if (salida && (_ultimoMovimiento == AccionRapida.salida || !entrada)) {
      unawaited(deshacerSalida(mensajero, widget.salidas));
    } else if (entrada) {
      unawaited(deshacerEntrada(mensajero, widget.entradas));
    }
  }

  void _nuevoProducto() => unawaited(
    mostrarDialogoNuevoProducto(
      context,
      widget.controlador,
      fotos: widget.fotos,
      proveedores: widget.proveedores.nombres,
      aBolivares: widget.tasa.aBolivares,
    ),
  );

  void _abrirProductos() => unawaited(
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaProductos(
          lista: widget.listaProductos,
          tasa: widget.tasa,
          fotos: widget.fotos,
          proveedores: widget.proveedores.nombres,
          onKardex: (producto) => _abrirKardex(producto.id),
        ),
      ),
    ),
  );

  void _verVentasDeHoy() => unawaited(
    mostrarVentasDeHoy(
      context,
      movimientos: widget.movimientos,
      salidas: widget.salidas,
      existencias: widget.controlador,
      devoluciones: widget.devoluciones,
      aBolivares: widget.tasa.aBolivares,
    ),
  );

  void _abrirKardex([String? productoId]) => unawaited(
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaKardex(
          movimientos: widget.movimientos,
          existencias: widget.controlador,
          productoId: productoId,
        ),
      ),
    ),
  );

  void _abrirConteo() => unawaited(
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaConteo(
          conteo: widget.conteo,
          existencias: widget.controlador,
        ),
      ),
    ),
  );

  void _ponerTasa() => unawaited(mostrarDialogoTasa(context, widget.tasa));

  void _abrirProveedores() => unawaited(
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaProveedores(
          controlador: widget.proveedores,
          existencias: widget.controlador,
          compras: widget.compras,
          incidencias: widget.incidencias,
          aBolivares: widget.tasa.aBolivares,
        ),
      ),
    ),
  );

  void _abrirIncidencias() => unawaited(
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaIncidencias(
          incidencias: widget.incidencias,
          existencias: widget.controlador,
          proveedores: widget.proveedores.nombres,
        ),
      ),
    ),
  );

  void _registrarIncidencia() => unawaited(
    mostrarDialogoIncidencia(
      context,
      incidencias: widget.incidencias,
      existencias: widget.controlador,
      proveedores: widget.proveedores.nombres,
    ),
  );

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    for (final accion in AccionRapida.values)
      SingleActivator(accion.tecla): () => _ejecutar(accion),
    const SingleActivator(LogicalKeyboardKey.keyK, control: true):
        _focoBusqueda.requestFocus,
    const SingleActivator(LogicalKeyboardKey.keyN, control: true):
        _nuevoProducto,
    const SingleActivator(LogicalKeyboardKey.keyL, control: true):
        widget.onBloquear,
    const SingleActivator(LogicalKeyboardKey.f5): _abrirProveedores,
    const SingleActivator(LogicalKeyboardKey.f6): _abrirIncidencias,
    const SingleActivator(LogicalKeyboardKey.f7): _verVentasDeHoy,
    const SingleActivator(LogicalKeyboardKey.f8): _abrirKardex,
    const SingleActivator(LogicalKeyboardKey.f9): _abrirConteo,
    const SingleActivator(LogicalKeyboardKey.f10): _abrirCuentas,
    const SingleActivator(LogicalKeyboardKey.f11): _abrirCaja,
    const SingleActivator(LogicalKeyboardKey.f12): _abrirReportes,
    const SingleActivator(LogicalKeyboardKey.keyG, control: true):
        _registrarGasto,
    const SingleActivator(LogicalKeyboardKey.keyL, control: true, shift: true):
        widget.onCambiarPin,
    const SingleActivator(LogicalKeyboardKey.keyI, control: true):
        _registrarIncidencia,
    const SingleActivator(LogicalKeyboardKey.keyT, control: true): _ponerTasa,
    const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
        _deshacerMovimiento,
  };

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return PedirTasaSiFalta(
      tasa: widget.tasa,
      child: AtajosDeTeclado(
        atajos: _atajos,
        child: Scaffold(
          body: Column(
            children: [
              BarraSuperior(
                tasa: widget.tasa,
                onTasa: _ponerTasa,
                onProveedores: _abrirProveedores,
                onIncidencias: _abrirIncidencias,
                onKardex: _abrirKardex,
                onConteo: _abrirConteo,
                onCuentas: _abrirCuentas,
                onCaja: _abrirCaja,
                onReportes: _abrirReportes,
                onBloquear: widget.onBloquear,
                onCambiarPin: widget.onCambiarPin,
              ),
              ListenableBuilder(
                listenable: widget.tasa,
                builder: (context, _) => widget.tasa.esDeHoy
                    ? const SizedBox.shrink()
                    : AvisoTasa(controlador: widget.tasa, onPoner: _ponerTasa),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, limites) {
                    final lateral = math.max(
                      espaciado.xl,
                      (limites.maxWidth - PantallaInicio._anchoMaximo) / 2,
                    );
                    return ListenableBuilder(
                      listenable: widget.controlador,
                      builder: (context, _) => CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              lateral,
                              espaciado.xl,
                              lateral,
                              espaciado.xl,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                spacing: espaciado.xl,
                                children: [
                                  AccionesRapidas(onAccion: _ejecutar),
                                  PanelDelDia(
                                    movimientos: widget.movimientos,
                                    existencias: widget.controlador,
                                    tasa: widget.tasa,
                                    onVerVentas: _verVentasDeHoy,
                                  ),
                                  CabeceraExistencias(
                                    controlador: widget.controlador,
                                    focoBusqueda: _focoBusqueda,
                                    onNuevoProducto: _nuevoProducto,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              lateral,
                              0,
                              lateral,
                              espaciado.xl,
                            ),
                            sliver: GrillaProductos(
                              estado: widget.controlador.estado,
                              productos: widget.controlador.visibles,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
