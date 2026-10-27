import 'package:flutter/foundation.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/transacciones.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';
import 'package:inventario/features/salidas/domain/devolucion_cliente.dart';
import 'package:inventario/features/salidas/domain/devolver_venta.dart';
import 'package:inventario/features/salidas/domain/modo_venta.dart';
import 'package:inventario/features/salidas/domain/movimiento_de_venta.dart';
import 'package:inventario/features/salidas/domain/pago_venta.dart';
import 'package:inventario/features/salidas/domain/repositorio_ventas.dart';
import 'package:inventario/features/salidas/domain/resultado_anulacion.dart';
import 'package:inventario/features/salidas/domain/resultado_cobro.dart';
import 'package:inventario/features/salidas/domain/resultado_salida.dart';
import 'package:inventario/features/salidas/domain/resumen_cobro.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/domain/ticket.dart';
import 'package:inventario/features/salidas/domain/vender.dart';
import 'package:inventario/features/salidas/domain/vender_ticket.dart';
import 'package:inventario/features/salidas/domain/venta.dart';

typedef _UltimaVenta = ({
  List<CambioProducto> cambios,
  List<Movimiento> anotados,
  Venta? venta,
});

/// Takes sold goods out of the stock and remembers the last sale so it can
/// be undone. Also remembers how each product was last sold, to offer it.
class ControladorSalidas extends ChangeNotifier {
  ControladorSalidas(
    this._existencias, {
    this._movimientos,
    this._ventas,
    this._tasaDeHoy,
    this._transacciones = const SinTransaccion(),
  });

  final ControladorExistencias _existencias;

  /// Stock and history change together or not at all.
  final Transacciones _transacciones;

  /// Where each sale is noted for the day's history; optional in tests.
  final ControladorMovimientos? _movimientos;

  /// Where paid tickets and their payments are kept; optional in tests.
  final RepositorioVentas? _ventas;

  /// Today's Bs per dollar, null while missing; each sale keeps the one it
  /// used. Without it (tests) sales go through with no rate.
  final int? Function()? _tasaDeHoy;
  final _ultimoModo = <String, ModoVenta>{};
  _UltimaVenta? _ultima;

  bool get puedeDeshacer => _ultima != null;

  /// The ticket being rung up; kept when its window closes, so Esc never
  /// loses it. Emptied once it is paid.
  Ticket ticketEnCurso = const Ticket();

  /// Offered first in the next payment.
  MedioPago ultimoMedio = MedioPago.efectivoDolares;

  int? get tasaDeHoy => _tasaDeHoy?.call();

  /// Whole piece unless this product was last sold by weight.
  ModoVenta modoPara(String productoId) =>
      _ultimoModo[productoId] ?? ModoVenta.piezaEntera;

  Future<ResultadoSalida> registrar(String productoId, Salida salida) async {
    final tasa = _tasaDeHoy?.call();
    if (_tasaDeHoy != null && tasa == null) return const SinTasaDelDia();
    final antes = _buscar(productoId);
    if (antes == null) return const SalidaSinProducto();
    final despues = vender(antes, salida);
    if (despues == null) return const SinExistencias();
    return _transacciones.enUna(() async {
      final resultado = await _existencias.actualizarProducto(
        productoId,
        DatosProducto.desde(despues),
      );
      switch (resultado) {
        case ProductoGuardado(:final producto):
          final anotado = await _movimientos?.anotar(
            _movimientoDe(antes, salida, tasa),
          );
          _recordarModo(productoId, salida);
          _ultima = (
            cambios: [(antes: antes, despues: producto)],
            anotados: [?anotado],
            venta: null,
          );
          notifyListeners();
          return SalidaRegistrada(producto);
        // The name is unchanged, so it cannot clash with another product.
        case NombreRepetido():
          return const SalidaSinProducto();
      }
    });
  }

  /// Sells every line of [ticket] and keeps how it was paid, all at once.
  Future<ResultadoCobro> cobrar(Ticket ticket, List<PagoVenta> pagos) async {
    final tasa = _tasaDeHoy?.call();
    final enBolivares = pagos.any((p) => p.medio.moneda == Moneda.bolivares);
    if ((_tasaDeHoy != null || enBolivares) && tasa == null) {
      return const CobroSinTasa();
    }
    final cobro = ResumenCobro(
      total: ticket.total,
      pagos: pagos,
      tasa: tasa ?? 0,
    );
    if (ticket.vacio || !cobro.puedeRegistrarse) return const CobroIncompleto();
    final (:cambios, :sinExistencias) = venderTicket(ticket, _buscar);
    if (sinExistencias != null) return CobroSinExistencias(sinExistencias);
    final hecho = await _transacciones.enUna(() async {
      final datos = Venta(
        fecha: DateTime.now(),
        total: ticket.total,
        tasa: tasa,
        pagos: pagos,
      );
      final venta = await _ventas?.registrar(datos) ?? datos;
      for (final cambio in cambios) {
        await _existencias.actualizarProducto(
          cambio.antes.id,
          DatosProducto.desde(cambio.despues),
        );
      }
      final anotados = await _anotarLineas(ticket, cambios, tasa, venta.id);
      return (venta: venta, anotados: anotados);
    });
    for (final linea in ticket.lineas) {
      _recordarModo(linea.productoId, linea.salida);
    }
    ticketEnCurso = const Ticket();
    ultimoMedio = pagos.last.medio;
    _ultima = (
      cambios: [
        for (final c in cambios)
          (antes: c.antes, despues: _buscar(c.antes.id)!),
      ],
      anotados: hecho.anotados,
      venta: hecho.venta,
    );
    notifyListeners();
    return VentaCobrada(hecho.venta);
  }

  /// Puts the products back as they were before the last sale. Refused
  /// (false) when something else changed one of them since, to not lose it.
  Future<bool> deshacer() async {
    final ultima = _ultima;
    if (ultima == null) return false;
    _ultima = null;
    notifyListeners();
    if (ultima.cambios.any((c) => _buscar(c.despues.id) != c.despues)) {
      return false;
    }
    // A return already hangs from it: undoing would leave it orphaned.
    final historial = _movimientos?.todos ?? const <Movimiento>[];
    if (ultima.anotados.any((m) => yaDevuelto(m, historial) > 0)) return false;
    return _transacciones.enUna(() async {
      var bien = true;
      for (final cambio in ultima.cambios) {
        final resultado = await _existencias.actualizarProducto(
          cambio.antes.id,
          DatosProducto.desde(cambio.antes),
        );
        bien = bien && resultado is ProductoGuardado;
      }
      for (final anotado in ultima.anotados) {
        await _movimientos?.quitar(anotado);
      }
      if (ultima.venta case final venta? when venta.id.isNotEmpty) {
        await _ventas?.quitar(venta.id);
      }
      return bien;
    });
  }

  /// Gives a sale's goods back to its brand lot and keeps the sale in the
  /// day's list, crossed out. Unlike undo, it works on any sale of the day.
  Future<ResultadoAnulacion> anular(Movimiento venta) async {
    if (venta.anulada) return const YaAnulada();
    if (yaDevuelto(venta, _movimientos?.todos ?? const []) > 0) {
      return const AnulacionConDevolucion();
    }
    final producto = _buscar(venta.productoId);
    if (producto == null) return const AnulacionSinProducto();
    final devuelto = devolverVenta(
      producto,
      marca: venta.marca,
      proveedor: venta.proveedor,
      piezas: venta.piezas,
      cantidad: venta.cantidad,
      abrioPieza: venta.abrioPieza,
    );
    await _transacciones.enUna(() async {
      await _existencias.actualizarProducto(
        producto.id,
        DatosProducto.desde(devuelto),
      );
      await _movimientos?.anular(venta.id);
    });
    // That sale can no longer be undone on top of the cancellation.
    if (_ultima?.anotados.any((m) => m.id == venta.id) ?? false) {
      _ultima = null;
    }
    notifyListeners();
    return const VentaAnulada();
  }

  /// One movement per line, each priced against its lot as it was right
  /// before that line (two lines can share a lot).
  Future<List<Movimiento>> _anotarLineas(
    Ticket ticket,
    List<CambioProducto> cambios,
    int? tasa,
    String ventaId,
  ) async {
    final estado = {for (final c in cambios) c.antes.id: c.antes};
    final anotados = <Movimiento>[];
    for (final linea in ticket.lineas) {
      final antes = estado[linea.productoId]!;
      final anotado = await _movimientos?.anotar(
        _movimientoDe(
          antes,
          linea.salida,
          tasa,
          ventaId: ventaId.isEmpty ? null : ventaId,
        ),
      );
      if (anotado != null) anotados.add(anotado);
      estado[linea.productoId] = vender(antes, linea.salida)!;
    }
    return anotados;
  }

  Movimiento _movimientoDe(
    Producto antes,
    Salida salida,
    int? tasa, {
    String? ventaId,
  }) => movimientoDeVenta(
    antes,
    salida,
    fecha: DateTime.now(),
    tasa: tasa,
    ventaId: ventaId,
  );

  void _recordarModo(String productoId, Salida salida) {
    if (salida.modo case final modo?) _ultimoModo[productoId] = modo;
  }

  Producto? _buscar(String id) {
    for (final producto in _existencias.productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }
}
